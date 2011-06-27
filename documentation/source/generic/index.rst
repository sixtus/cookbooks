Part 1 - Generic Documentation
==============================

This part describes the technologies (and their fundamental usage) used by
computer systems implemented according to this manual and the site-specific
specifications and policies defined in :doc:`../local/index`.

This part requires a basic understandig of Linux/Unix system administration
including package management, user management, using a text editor such as vi
and some basic network and service management skills.

Specifically, the foundation for all systems implemented according to this
manual is `Gentoo Linux`_ - a very powerful and for beginners sometimes complex
Linux distribution. To get started you should have at least read the `Working
with Gentoo`_ and `Working with Portage`_ sections of the `Gentoo Handbook`_.

All systems will then be bootstrapped and deployed with `Chef`_, an open-source
systems integration framework built specifically for automating the datacenter
or cloud. No matter how complex the realities of the business, Chef makes it
easy to deploy servers and scale applications throughout the entire
infrastructure. Because it combines the fundamental elements of configuration
management and service oriented architectures with the full power of `Ruby`_,
Chef makes it easy to create an elegant, fully automated infrastructure.

Eventually the reconstruction of the business can be accomplished from nothing
but a source code repository, an application data backup, and bare metal
resources.

Contents
--------

.. toctree::
   :maxdepth: 1

   chef/index
   user
   maintenance
   monitoring
   metrics
   backup
   archiving


.. _Gentoo Linux: http://www.gentoo.org
.. _Working with Gentoo: http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?part=2
.. _Working with Portage: http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?part=3
.. _Gentoo Handbook: http://www.gentoo.org/doc/en/handbook/handbook-amd64.xml
.. _Chef: http://www.opscode.com/chef/
.. _Ruby: http://www.ruby-lang.org
