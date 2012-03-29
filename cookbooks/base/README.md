Usage
=====

The base system cookbook should be used by all nodes. It is added to the run
list -- together with various other common services -- in `role[base]` and will
configure the following programs and services:

Cookbooks
  : These cookbooks are included by `recipe[base]` depending on the
  platform, virtualization type and hardware support:

    * git
    * hwraid
    * lftp
    * mdadm
    * ntp
    * openssl
    * portage
    * shorewall
    * smart
    * tmux
    * vim

Version Control for /etc
  : On all nodes `/etc` is managed with git, so changes can be tracked easily.
  The base recipe will automatically commit any pending changes before doing
  any modification to the system.

Resolver Configuration
  : The resolver is a set of routines in the C library that provide access to the
  Internet Domain Name System (DNS). See the attributes documentation below for
  details on how chef generates `/etc/hosts` and `/etc/resolv.conf`.

System Initialization (Linux only)
  : The inittab file describes which processes are started at bootup and during
  normal operation. This file is rarely modified since control is handed of to
  OpenRC once the system initialization has been done. OpenRC is a dependency
  based init system that works with the system provided init program and is
  therefore not a replacement for /sbin/init.

  : For a detailed description of /sbin/init and OpenRC -- including
  documentation on how to write init scripts -- see [Chapter 2.4 of the Gentoo
  Handbook][].

Localization (Linux only)
  : Time zone information, system locales and character encodings are
  configured according to the attributes documented below. For a detailed
  description on localization support in Gentoo refer to the [Gentoo
  Localization Guide][].

[Chapter 2.4 of the Gentoo Handbook]: http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?part=2&chap=4
[Gentoo Localization Guide]: http://www.gentoo.org/doc/en/guide-localization.xml


Attributes
==========

The base system cookbook contains various attributes for basic functionality
provided by supported platforms including locales, timezones, resolver config etc.

Cluster Support
---------------

`cluster[:name] = "default"`
  : Partition the infrastructure into clusters. This is used by `/etc/hosts`,
  nagios, the documentation generator and various other places.

Contacts
--------

`contacts[:hostmaster] = "root@#{node[:fqdn]}"`
  : The administrative contact for this node. Used by cron, postfix-satelite
  and various other scripts.

Localization
------------

`timezone = "Europe/Berlin"`
  : This nodes timezone. For a list of available timezones see
  `/usr/share/zoneinfo`.

`locales = ["en_US.UTF-8 UTF-8", "de_DE.UTF-8 UTF-8"]`
  : A list of locales available on this node. For a list of available locales
  see `/usr/share/i18n/locales`.

Resolver
--------

`resolv[:nameservers] = %w(8.8.8.8 8.8.4.4)`
  : Internet addresses (in dot notation) of name servers that the resolver
  should query. Up to MAXNS (currently 3, see `<resolv.h>`) name servers may be
  listed.  If there are multiple servers, the resolver library queries them in
  the order listed. The default is using Googles Public Anycast DNS service.

`resolv[:search] = [node[:domain]]`
  : Search list for host-name lookup. The search list is normally determined
  from the local domain name; by default, it contains only the local domain
  name.  This may be changed by listing the desired domain search path.
  Resolver queries having fewer than  ndots dots  (default is 1) in them will
  be attempted using each component of the search path in turn until a match is
  found.

`resolv[:hosts] = []`
  : List of additional entries in `/etc/hosts` which cannot be generated from
  Chefs SOLR index.

`resolv[:aliases] = []`
  : List of additional hostname aliases for this node. These are added as
  entries in `/etc/hosts` for nodes in the same cluster.

Kernel Options
--------------

`sysctl[:kernel][:sysrq] = 1`
  : Enable the SysRq key combination. See [Linux Documentation on SysRq][] for
  details.

[Linux Documentation on SysRq]: http://www.kernel.org/doc/Documentation/sysrq.txt

`sysctl[:kernel][:panic] = 60`
  : The number of seconds the kernel waits before rebooting on a panic. When
  you use the software watchdog, the recommended setting is 60.

Virtual Memory Options
----------------------

`sysctl[:vm][:overcommit_ratio] = 95`
  : ..

`sysctl[:vm][:overcommit_memory] = 0`
  : ..

Shared Memory Sizes
-------------------

`sysctl[:kernel][:shmall] = 2*1024*1024`
  : ..

`sysctl[:kernel][:shmmax] = 32*1024*1024`
  : This value can be used set the run time limit on the maximum shared memory
  segment size that can be created.  Shared memory segments up to 1Gb are now
  supported in the kernel.

`sysctl[:kernel][:shmmni] = 4096`
  : ..

Network Tuning
--------------

`sysctl[:net][:core][:somaxconn] = 128`
  : ..

`sysctl[:net][:ipv4][:ip_local_port_range] = "32768 61000"`
  : ..

`sysctl[:net][:ipv4][:tcp_fin_timeout] = 60`
  : The tcp_fin_timeout variable tells kernel how long to keep sockets in the
  state FIN-WAIT-2 if you were the one closing the socket. This is used if the
  other peer is broken for some reason and don't close its side, or the other
  peer may even crash unexpectedly. Each socket left in memory takes
  approximately 1.5Kb of memory

`sysctl[:net][:ipv4][:tcp_max_syn_backlog] = 2048`
  : The `tcp_max_syn_backlog` variable tells your box how many SYN requests to
  keep in memory that we have yet to get the third packet in a 3-way handshake
  from. The `tcp_max_syn_backlog` variable is overridden by the
  `tcp_syncookies` variable, which needs to be turned on for this variable to
  have any effect.  If the server suffers from overloads at peak times, you may
  want to increase this value a little bit.

`sysctl[:net][:ipv4][:tcp_syncookies] = 1`
  : ..

`sysctl[:net][:ipv4][:tcp_tw_recycle] = 0`
  : This variable enables the fast recycling function of TIME-WAIT sockets.
  Unless you know what you are doing you should not touch this function at all.

`sysctl[:net][:ipv4][:tcp_tw_reuse] = 0`
  : This allows reusing sockets in TIME-WAIT state for new connections when it
  is safe from protocol viewpoint. Default value is 0 (disabled). It is
  generally a safer alternative to `tcp_tw_recycle`.


`sysctl[:net][:netfilter][:nf_conntrack_max] = 262144`
  : The size of the Netfilter connection tracking table. If you have a lot of
  connections (e.g. on a load balancer) this value has to be increased at the
  cost of a few megabytes of memory (~30MiB for 100.000 connections).

Miscelaneous
------------

`packages = [...]`
  : This list contains packages that should be installed on all systems. This
  includes various system and  network analysis tools, shel completion,
  archiving tools etc. For a complete list see the `attributes/default.rb`
  file in the base cookbook source.


Nagios Service Checks
=====================

The base system recipe will register the following nagios service checks
with the chef server.

PING
----

PROCS
-----

ZOMBIES
-------

LOAD
----

DISKS
-----

RAID
----

SWAP
----

LINK
----

Munin Metrics
=============

The base system recipe will install the following Munin plugins.

CPU Usage
---------

Disk Usage
----------

Available Entropy
-----------------

Forks per Second
----------------

Load Average
------------

Memory Usage
------------

File Table Usage
----------------

Inode Table Usage
-----------------

Processes
---------

IOstat
------

Swap In/Out
-----------

VMstat
------

