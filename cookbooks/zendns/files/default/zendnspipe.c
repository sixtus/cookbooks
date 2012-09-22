#define _GNU_SOURCE

#include <stdio.h>
#include <signal.h>
#include <ctype.h>

#include "mongo.h"

#define xfree(p) { free(p); p = NULL; }

#ifdef DEBUG
#define debug(...) fprintf(stderr, __VA_ARGS__)
#else
#define debug(...) do {} while(0)
#endif

#define mongo_query(cursor, query, ns) do { \
    mongo_cursor_init(cursor, dbh, ns); \
    mongo_cursor_set_query(cursor, query); \
} while (0)

static const char *backend_name = "[ZenDNSBackend]";

static mongo dbh[1];

static
int get_domain_cursor(bson *query, mongo_cursor *cursor, char *qname, int domain_id)
{
    int found = 0;

    if (domain_id > 0) {
        debug("trying to find domain with id=%d\n", domain_id);

        bson_init(query);
        bson_append_int(query, "_id", domain_id);
        bson_finish(query);

        mongo_query(cursor, query, "zendns_production.domains");

        if (mongo_cursor_next(cursor) == MONGO_OK) {
            found = 1;
        } else {
            mongo_cursor_destroy(cursor);
        }
    }

    else {
        char *sdom = qname;

        while (!found && sdom) {
            debug("trying to find domain with name=%s\n", sdom);

            bson_init(query);
            bson_append_string(query, "name", sdom);
            bson_finish(query);

            mongo_query(cursor, query, "zendns_production.domains");

            if (mongo_cursor_next(cursor) == MONGO_OK) {
                found = 1;
                break;
            } else {
                mongo_cursor_destroy(cursor);
            }

            if ((sdom = strchr(sdom, '.')) != NULL) {
                sdom++;
            }
        }
    }

    return found;
}

static
void print_domain(char *qname, int *domain_id, char **domain_name, char **soa)
{
    bson query[1];
    mongo_cursor cursor[1];

    if (get_domain_cursor(query, cursor, qname, *domain_id) == 0) {
        return;
    }

    const bson *doc = mongo_cursor_bson(cursor);
    bson_iterator iterator[1];

    if (bson_find(iterator, doc, "_id")) {
        *domain_id = bson_iterator_int(iterator);
        debug("found domain_id=%d\n", *domain_id);
    }

    if (bson_find(iterator, doc, "name")) {
        *domain_name = strdup(bson_iterator_string(iterator));
        debug("found domain_name=%s\n", *domain_name);
    }

    // build SOA record
    const char *nameserver = NULL;
    if (bson_find(iterator, doc, "nameserver")) {
        nameserver = bson_iterator_string(iterator);
    }

    const char *hostmaster = NULL;
    if (bson_find(iterator, doc, "hostmaster")) {
        hostmaster = bson_iterator_string(iterator);
        char *p = strchr(hostmaster, '@');
        *p = '.';
    }

    int serial = 1;
    if (bson_find(iterator, doc, "serial")) {
        serial = bson_iterator_int(iterator);
    }

    int ttl = 7200;
    if (bson_find(iterator, doc, "ttl")) {
        ttl = bson_iterator_int(iterator);
    }

    fprintf(stdout, "DATA\t%s\tIN\t%s\t%d\t%d\t%s. %s. %d %d 3600 604800 3600\n",
            *domain_name, "SOA", 7200, *domain_id,
            nameserver, hostmaster, serial, ttl);
    fflush(stdout);

    mongo_cursor_destroy(cursor);
    bson_destroy(query);
}

static
void print_record(mongo_cursor *cursor, const char *domain_name)
{
    const bson *doc = mongo_cursor_bson(cursor);
    bson_iterator iterator[1];

    char *rname = NULL;
    const char *rtype = NULL;
    const char *content = NULL;
    int ttl = -1;
    int id = -1;

    if (bson_find(iterator, doc, "name")) {
        const char *name = bson_iterator_string(iterator);
        if (strcmp(name, "") == 0) {
            rname = strdup(domain_name);
        } else {
            asprintf(&rname, "%s.%s", bson_iterator_string(iterator), domain_name);
        }
    }

    if (bson_find(iterator, doc, "type")) {
        rtype = bson_iterator_string(iterator);
    }

    if (bson_find(iterator, doc, "content")) {
        content = bson_iterator_string(iterator);
    }

    if (bson_find(iterator, doc, "ttl")) {
        ttl = bson_iterator_int(iterator);
    }

    if (bson_find(iterator, doc, "_id")) {
        id = bson_iterator_int(iterator);
    }

    if (rname && rtype && content && ttl > 0 && id > 0) {
        fprintf(stdout, "DATA\t%s\tIN\t%s\t%d\t%d\t%s\n", rname, rtype, ttl, id, content);
        fflush(stdout);
    }

    xfree(rname);
}

static
void print_records(char *qtype, char *qname, const char *domain_name, int domain_id)
{
    // the host part of the query is the qname less the domain name
    char *host = NULL;
    size_t strdiff = strlen(qname) - strlen(domain_name);

    if (strdiff > 0) {
        host = strndup(qname, strdiff - 1);
    }

    debug("getting records for qtype=%s, host=%s, domain_name=%s, domain_id=%d\n", qtype, host, domain_name, domain_id);

    bson query[1];
    bson_init(query);

    bson_append_int(query, "domain_id", domain_id);

    // AXFR has no qtype
    if (qtype) {
        if (host) {
            bson_append_string(query, "name", host);
        } else {
            bson_append_string(query, "name", "");
        }

        if (strcmp(qtype, "ANY") != 0) {
            bson_append_string(query, "type", qtype);
        }
    }

    bson_finish(query);

    mongo_cursor cursor[1];
    mongo_query(cursor, query, "zendns_production.records");

    while (mongo_cursor_next(cursor) == MONGO_OK) {
        print_record(cursor, domain_name);
    }

    debug("record lookup done\n");

    mongo_cursor_destroy(cursor);
    bson_destroy(query);

    if (host) {
        xfree(host);
    }
}

static
void process_query(char *line)
{
    // tokenize query
    char *q = strsep(&line, "\t");
    char *qname = strsep(&line, "\t\n");
    char *qclass = strsep(&line, "\t");
    char *qtype = strsep(&line, "\t");
    char *id = strsep(&line, "\t");
    char *remote_ip = strsep(&line, "\n");

    int domain_id = 0;
    char *domain_name = NULL;
    char *soa = NULL;

    // sanity checks
    if (!q || (strcmp(q, "Q") != 0 && strcmp(q, "AXFR") != 0)) {
        fprintf(stdout, "FAIL\tinvalid question format: '%s'\n", q);
        fflush(stdout);
        return;
    }

    if (strcmp(q, "AXFR") == 0) {
        if (!qname) {
            fprintf(stdout, "FAIL\tincomplete question\n");
            fflush(stdout);
            return;
        }

        domain_id = atoi(qname);
        debug("starting AXFR with domain_id=%d\n", domain_id);
    }

    else {
        if (!qname || !qclass || !qtype || !id || !remote_ip) {
            fprintf(stdout, "FAIL\tincomplete question\n");
            fflush(stdout);
            return;
        }

        if (strcmp(qclass, "IN") != 0) {
            fprintf(stdout, "FAIL\tinvalid qclass: '%s'\n", qclass);
            fflush(stdout);
            return;
        }

        for (int i = 0; qname[i]; i++){
            qname[i] = tolower(qname[i]);
        }

        debug("starting normal record lookup with qname=%s\n", qname);
    }

    print_domain(qname, &domain_id, &domain_name, &soa);

    if (domain_id > 0 && domain_name) {
        print_records(qtype, qname, domain_name, domain_id);
    }

    xfree(domain_name);

    fprintf(stdout, "END\n");
    fflush(stdout);
}

static
void process(void)
{
    char *line = NULL;
    size_t len = 0;
    ssize_t read;

    while ((read = getline(&line, &len, stdin)) != -1) {
        if (strcmp(line, "HELO\t1\n") == 0)
            break;
        xfree(line);
    }

    xfree(line);
    fprintf(stdout, "OK\tZenDNS backend initialized sucessfully\n");
    fflush(stdout);

    while ((read = getline(&line, &len, stdin)) != -1) {
        process_query(line);
        xfree(line);
    }
}

static
void disconnect(void)
{
    if (dbh->connected) {
        mongo_destroy(dbh);
    }
}

static
void connect(void)
{
    mongo_replset_init(dbh, "zendns");
    mongo_replset_add_seed(dbh, "127.0.0.1", 27017);

    int status = mongo_replset_connect(dbh);

    if (status != MONGO_OK) {
        fprintf(stderr, "%s failed to connect to MongoDB: ", backend_name);

        switch (dbh->err) {
            case MONGO_CONN_NO_SOCKET:  fprintf(stderr, "no socket\n"); break;
            case MONGO_CONN_FAIL:       fprintf(stderr, "connection failed\n"); break;
            case MONGO_CONN_ADDR_FAIL:  fprintf(stderr, "invalid address\n"); break;
        }

        fflush(stderr);
        exit(1);
    }

    atexit(disconnect);
}

static
void sig_exit(int sig)
{
    exit(1);
}

int main()
{
    signal(SIGINT, sig_exit);
    signal(SIGQUIT, sig_exit);
    signal(SIGTERM, sig_exit);

    connect();
    process();
    disconnect();
    return 0;
}

// vim: et
