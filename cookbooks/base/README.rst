.. _chef-cookbook-base:

===========
Base System
===========

This cookbook installs and configures the Gentoo base system.

Usage
=====

The base system cookbook should be used by all nodes. It is available -- together
with various other common services -- in ``role[base]`` and will configure the
following programs and services:

Cookbooks
  These cookbooks are included by ``recipe[base]`` depending on the
  virtualization type and hardware support:

  * :ref:`chef-cookbook-portage`
  * :ref:`chef-cookbook-openssl`
  * :ref:`chef-cookbook-git`
  * :ref:`chef-cookbook-lftp`
  * :ref:`chef-cookbook-tmux`
  * :ref:`chef-cookbook-vim`
  * :ref:`chef-cookbook-hwraid`
  * :ref:`chef-cookbook-mdadm`
  * :ref:`chef-cookbook-ntp`
  * :ref:`chef-cookbook-shorewall`
  * :ref:`chef-cookbook-smart`
  * :ref:`chef-cookbook-pkgsync`

``/etc/.git``
  On all nodes ``/etc`` is managed with git, so changes can be tracked easily.
  The base recipe will automatically commit any pending changes before doing any
  modification to the system.

Resolver Configuration
  The resolver is a set of routines in the C library that provide access to the
  Internet Domain Name System (DNS). See the attributes documentation below for
  details on how chef generates ``/etc/hosts`` and ``/etc/resolv.conf``.

System Initialization
  The inittab file describes which processes are started at bootup and during
  normal operation. This file is rarely modified since control is handed of to
  OpenRC once the system initialization has been done. OpenRC is a dependency
  based init system that works with the system provided init program and is
  therefore not a replacement for /sbin/init.

  For a detailed description of /sbin/init and OpenRC -- including
  documentation on how to write init scripts -- see
  `Chapter 2.4 of the Gentoo Handbook
  <http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?part=2&chap=4>`_.

Localization
  Time zone information, system locales and character encodings are configured
  according to the attributes documented below. For a detailed description on
  localization support in Gentoo refer to the `Gentoo Localization Guide
  <http://www.gentoo.org/doc/en/guide-localization.xml>`_.


Attributes
==========

The base system cookbook contains various attributes for basic functionality
provided by Gentoo Linux including locales, timezones, resolver config etc.

.. rubric:: Cluster Support

``cluster[:name] = "default"``
  Partition the infrastructure into clusters. This is used by /etc/hosts,
  nagios, the documentation generator and various other places.

.. rubric:: Contacts

``contacts[:hostmaster] = "root@#{node[:fqdn]}"``
  The administrative contact for this node. Used by cron, postfix-satelite and
  various other scripts.

.. rubric:: Localization

``timezone = "Europe/Berlin"``
  This nodes timezone. For a list of available timezones see
  ``/usr/share/zoneinfo``.

``locales = ["en_US.UTF-8 UTF-8", "de_DE.UTF-8 UTF-8"]``
  A list of locales available on this node. For a list of available locales see
  ``/usr/share/i18n/locales``.

.. rubric:: Resolver

``resolv[:nameservers] = %w(8.8.8.8 8.8.4.4)``
  Internet addresses (in dot notation) of name servers that the resolver should
  query. Up to MAXNS (currently 3, see <resolv.h>) name servers may be listed.
  If there are multiple servers, the resolver library queries them in the order
  listed. The default is using Googles Public Anycast DNS service.

``resolv[:search] = [node[:domain]``
  Search list for host-name lookup. The search list is normally determined from
  the local domain name; by default, it contains only the local domain name.
  This may be changed by listing the desired domain search path. Resolver
  queries having fewer than  ndots dots  (default is 1) in them will be
  attempted using each component of the search path in turn until a match is
  found.

``resolv[:hosts] = []``
  List of additional entries in ``/etc/hosts`` which cannot be generated from
  Chefs SOLR index.

.. rubric:: Sysctl

``sysctl[:net][:ipv4][:ip_forward] = 0``
  Enable IPv4 Forwarding (required for NAT).

``sysctl[:net][:netfilter][:nf_conntrack_max] = 262144``
  The size of the Netfilter connection tracking table. If you have a lot of
  connections (e.g. on a load balancer) this value has to be increased at the
  cost of a few megabytes of memory (~30MiB for 100.000 connections).

``sysctl[:kernel][:sysrq] = 1``
  Enable the SysRq key combination. See
  http://www.kernel.org/doc/Documentation/sysrq.txt for details.

``sysctl[:kernel][:panic] = 60``
  The number of seconds the kernel waits before rebooting on a panic. When you
  use the software watchdog, the recommended setting is 60.

``sysctl[:kernel][:shmall] = 2*1024*1024``
  ..

``sysctl[:kernel][:shmmax] = 32*1024*1024``
  This value can be used set the run time limit on the maximum shared memory
  segment size that can be created.  Shared memory segments up to 1Gb are now
  supported in the kernel.

``sysctl[:kernel][:shmmni] = 4096``
  ..

.. rubric:: Miscelaneous

``packages = [...]``
  This list contains packages that should be installed on all systems. This
  includes various system and  network analysis tools, shel completion,
  archiving tools etc. For a complete list see the ``attributes/default.rb``
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

