#!/bin/bash

HAGROUP=${1:-<%= node[:postgresql][:ha][:group] %>}
PGDATA=${2:-/var/lib/postgresql/<%= node[:postgresql][:server][:version] %>/data}
DAEMON=${3:-postgresql@<%= node[:postgresql][:server][:version] %>.service}
CONSUL_SERVICE=/var/app/consul/shared/config/services/postgresql-ha.json

KV_MASTER="postgresql/${HAGROUP}/master"
HOSTNAME=`hostname -f`

function psql_get {
  /usr/bin/psql -U postgres -t -P format=unaligned -c "$1"
}

function check_master {
  MASTER_UP=false
  if [[ $( /usr/bin/psql -U postgres -h $MASTER -t -P format=unaligned -c "SELECT pg_is_in_recovery();" ) == "f" ]]; then
    MASTER_UP=true
  fi
}

function check_daemon {
  DAEMON_UP=false
  DAEMON_MASTER=false
  psql_get "select true;" > /dev/null
  if [[ $? -eq 0 ]]; then
    DAEMON_UP=true
    if [[ $( psql_get "SELECT pg_is_in_recovery();" ) == "f" ]]; then
      DAEMON_MASTER=true
    fi
  fi
}

function init_config {
  /var/app/consul/current/consul-template -once \
    -template=/var/app/postgresql/template/pg_hba.conf.ctmpl:$PGDATA/pg_hba.conf \
    -template=/var/app/postgresql/template/pg_ident.conf.ctmpl:$PGDATA/pg_ident.conf \
    -template=/var/app/postgresql/template/postgresql.conf.ctmpl:$PGDATA/postgresql.conf
}

function init_master {
    echo "adding a service to consul so I can be found"
    env HAGROUP=$HAGROUP /var/app/consul/current/consul-template -once \
      -template=/var/app/postgresql/template/postgresql-ha-master.json.ctmpl:$CONSUL_SERVICE
    sudo systemctl reload consul

    if [[ ! -a ${PGDATA}/PG_VERSION ]]; then
      echo "initial bootstrap, initializing..."
      /usr/bin/initdb --pgdata $PGDATA --locale=en_US.UTF-8 || exit 1
    fi

    init_config
    check_daemon

    if [ "$DAEMON_UP" == "false" ]; then
      rm -f $PGDATA/recovery.conf
      echo "(re-)starting $DAEMON"
      sudo systemctl restart $DAEMON
    elif [ "$DAEMON_MASTER" == "false" ]; then
      echo "promoting $DAEMON to master"
      /usr/bin/pg_ctl promote -D $PGDATA
    else
      echo "reloading $DAEMON to make sure it got a proper config"
      sudo systemctl reload $DAEMON
    fi
}

function elect_master {
  SESSION=`/var/app/consul/current/consul-cli kv-lock --ttl=60s --lock-delay=0 $KV_MASTER`
  if [[ "$?" != "0" ]]; then
    CONSUL_UP=false
    return
  else
    CONSUL_UP=true
  fi
  MASTER=`/var/app/consul/current/consul-cli kv-read $KV_MASTER`
  if [[ "$?" != "0" ]]; then
    CONSUL_UP=false
    return
  else
    CONSUL_UP=true
  fi

  FORCE_MASTER=false

  if [[ "$MASTER" == "" ]]; then
    echo "first election, I am master then"
    FORCE_MASTER=true
  elif [[ "$HOSTNAME" != "$MASTER" ]]; then
    check_master
    if [[ "$MASTER_UP" == "false" ]]; then
      echo "master $MASTER is not up... :("
      check_daemon
      if [[ "$DAEMON_UP" == "true" ]]; then
        echo "but I am up, so I'll become master now"
        FORCE_MASTER=true
      else
        echo "and I am also down, oh no!"
      fi
    fi
  fi

  if [[ "$FORCE_MASTER" == "true" ]]; then
    MASTER=$HOSTNAME
    /var/app/consul/current/consul-cli kv-write $KV_MASTER $MASTER
    if [[ "$?" != "0" ]]; then
      CONSUL_UP=false
      return
    else
      CONSUL_UP=true
    fi

    echo "I am master now"
    init_master
    echo "holding the election lock for 20sec so my daemon can start up"
    sleep 20
    check_master
    check_daemon
    echo "done, daemon up==$DAEMON_UP, master==$DAEMON_MASTER; master $MASTER accessible==$MASTER_UP"
  fi
  /var/app/consul/current/consul-cli kv-unlock --session=$SESSION $KV_MASTER
}

function ensure_slave {
  env HAGROUP=$HAGROUP /var/app/consul/current/consul-template -once \
    -template=/var/app/postgresql/template/postgresql-ha-slave.json.ctmpl:$CONSUL_SERVICE:'sudo systemctl reload consul'

  check_daemon

  if [[ "$DAEMON_MASTER" == "true" ]]; then
    # kill early, so consul down doesn't delay it
    echo "I am supposed to be slave, but $DAEMON reports to be master, stopping it NOW"
    sudo systemctl stop $DAEMON
    rm -f $PGDATA/recovery.conf # ensure we will eventually restart as slave
  fi

  OLD_RECOVERY=`cat $PGDATA/recovery.conf 2>/dev/null`

  # sadly, the output of -dry can't be compared directly, so detouring through .expected file
  /var/app/consul/current/consul-template -once \
    -template=/var/app/postgresql/template/recovery.conf.ctmpl:$PGDATA/recovery.expected
  if [[ "$?" != "0" ]]; then
    echo "consul seems down, skipping slave setup"
    return
  fi
  NEW_RECOVERY=`cat $PGDATA/recovery.expected`

  if [ "$OLD_RECOVERY" != "$NEW_RECOVERY" ] || [ "$DAEMON_MASTER" == "true" ] || [ "$DAEMON_UP" == "false" ]; then
    echo "old recovery.conf"
    echo $OLD_RECOVERY
    echo "new recovery.conf"
    echo $NEW_RECOVERY
    echo .
    echo "stopping $DAEMON"
    sudo systemctl stop $DAEMON

    echo "moving old $PGDATA to /var/app/postgresql/crashed"
    mkdir -p /var/app/postgresql/crashed
    mv $PGDATA /var/app/postgresql/crashed/`date +%Y-%m-%d-%k-%M-%S`

    echo "taking a base backup from $MASTER"
    /usr/bin/pg_basebackup -h $MASTER -D $PGDATA -v -P -U postgres --xlog-method=stream
    if [[ "$?" == "0" ]]; then
      echo "updating init files"
      init_config
      echo "setting up recovery.conf for master $MASTER"
      /var/app/consul/current/consul-template -once \
        -template=/var/app/postgresql/template/recovery.conf.ctmpl:$PGDATA/recovery.conf
      if [[ "$?" != "0" ]]; then
        echo "consul seems down, skipping slave setup"
        rm -f $PGDATA/recovery.conf
        return
      fi
      echo "starting $DAEMON in slave mode"
      sudo systemctl start $DAEMON
      echo "sleeping 20secs for dust to settle"
      sleep 20
      check_master
      check_daemon
      echo "done, daemon up==$DAEMON_UP, master==$DAEMON_MASTER; master $MASTER accessible==$MASTER_UP"
    else
      echo "taking base backup failed, not starting slave"
    fi
  fi
}

while [[ "$CONSUL_UP" != "true" ]]
do
  elect_master
done
echo "postgresql-ha in group $HAGROUP, data in $PGDATA, master is $MASTER"

while :
do
  elect_master
  if [[ "$CONSUL_UP" == "false" ]]; then
    echo "oh no, consul is down..."
  elif [[ "$HOSTNAME" != "$MASTER" ]]; then
    ensure_slave
  elif [[ "$MASTER_UP" == "false" ]]; then
    echo "my daemon is down... waiting for a slave to become master"
  fi
  sleep 1
done
