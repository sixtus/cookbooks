==========
PostgreSQL
==========

This cookbook installs and configures `PostgreSQL`_ clients and/or servers.

Usage
=====

On client nodes ``recipe[postgresql]`` will install the PostgreSQL client
libraries and development headers.

On server nodes ``recipe[postgresql::server]`` will install a PostgreSQL
server instance.

Attributes
==========

The PostgreSQL server supports a vast amount of configuration settings which cannot
be discussed in detail here. The most important settings are supported through
the following attributes. Where applicable best practice guidelines and
external resources are mentioned to help in optimizing server performance.

.. rubric:: Connections and Authentication

``postgresql[:server][:listen_address] = 'localhost'``
  Specifies the TCP/IP address(es) on which the server is to listen for
  connections from client applications. The value takes the form of a
  comma-separated list of host names and/or numeric IP addresses. The special
  entry * corresponds to all available IP interfaces. If the list is empty, the
  server does not listen on any IP interface at all, in which case only
  Unix-domain sockets can be used to connect to it. The default value is
  localhost, which allows only local TCP/IP "loopback" connections to be made.

``postgresql[:server][:port] = 5432``
  The TCP port the server listens on; 5432 by default. Note that the same port
  number is used for all IP addresses the server listens on.

``postgresql[:server][:max_connections] = 100``
  Determines the maximum number of concurrent connections to the database
  server.

  When running a standby server, you must set this parameter to the same or
  higher value than on the master server. Otherwise, queries will not be
  allowed in the standby server.

``postgresql[:server][:authentication_timeout] = "1min"``
  Maximum time to complete client authentication, in seconds. If a would-be
  client has not completed the authentication protocol in this much time, the
  server closes the connection. This prevents hung clients from occupying a
  connection indefinitely. The default is one minute (1m).

.. rubric:: Resource Consumption

``postgresql[:server][:shared_buffers] = "32MB"``
  Sets the amount of memory the database server uses for shared memory buffers.
  This setting must be at least 128 kilobytes. However, settings significantly
  higher than the minimum are usually needed for good performance.

  If you have a dedicated database server with 1GB or more of RAM, a reasonable
  starting value for shared_buffers is 25% of the memory in your system. There
  are some workloads where even large settings for shared_buffers are
  effective, but because PostgreSQL also relies on the operating system cache,
  it is unlikely that an allocation of more than 40% of RAM to shared_buffers
  will work better than a smaller amount.

``postgresql[:server][:temp_buffers] = "8MB"``
  Sets the maximum number of temporary buffers used by each database session.
  These are session-local buffers used only for access to temporary tables.

  A session will allocate temporary buffers as needed up to the limit given by
  temp_buffers. The cost of setting a large value in sessions that do not
  actually need many temporary buffers is only a buffer descriptor, or about 64
  bytes, per increment in temp_buffers. However if a buffer is actually used an
  additional 8192 bytes will be consumed for it.

``postgresql[:server][:work_mem] = "1MB"``
  Specifies the amount of memory to be used by internal sort operations and
  hash tables before writing to temporary disk files. The value defaults to one
  megabyte (1MB). Note that for a complex query, several sort or hash
  operations might be running in parallel; each operation will be allowed to
  use as much memory as this value specifies before it starts to write data
  into temporary files. Also, several running sessions could be doing such
  operations concurrently. Therefore, the total memory used could be many times
  the value of work_mem; it is necessary to keep this fact in mind when
  choosing the value. Sort operations are used for ORDER BY, DISTINCT, and
  merge joins. Hash tables are used in hash joins, hash-based aggregation, and
  hash-based processing of IN subqueries.

``postgresql[:server][:maintenance_work_mem] = "16MB"``
  Specifies the maximum amount of memory to be used by maintenance operations,
  such as VACUUM, CREATE INDEX, and ALTER TABLE ADD FOREIGN KEY. Since only one
  of these operations can be executed at a time by a database session, and an
  installation normally doesn't have many of them running concurrently, it's
  safe to set this value significantly larger than work_mem. Larger settings
  might improve performance for vacuuming and for restoring database dumps.

  Note that when autovacuum runs, up to autovacuum_max_workers times this
  memory may be allocated, so be careful not to set the default value too high.

.. rubric:: Write Ahead Log

``postgresql[:server][:wal_level] = "minimal"``

``postgresql[:server][:max_wal_senders] = 0``

``postgresql[:server][:wal_keep_segments] = 0``

``postgresql[:server][:hot_standby] = "off"``

