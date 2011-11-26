.. _chef-repository:

Repository
==========

The chef repository is a fundamental part of the architecture and fulfills the
first requirement from the overall goal as described in the introduction:

  Enable the reconstruction of the business from nothing but a source code
  repository, an application data backup, and bare metal resources

The chef repository stores all source code necessary to bootstrap the entire
infrastructure. The root of the directory tree contains the following files and
folders:

.. sidebar:: Ruby, RVM and Bundler

   RVM allows users to deploy each project with its own completely
   self-contained and dedicated environment--from the specific version of ruby
   all the way down to the precise set of required gems to run the application.

   Together with Bundler, a tool that manages an application's dependencies
   through its entire life across many machines systematically and repeatably,
   the chef repository can be set up in a portable way in no time.

   For help setting up Ruby, RVM and Bundler see
   :ref:`tutorial-ruby-rvm-bundler`.

**.rvmrc**
   repository-specific configuration file for `RVM`_. See the documentation for
   `Project .rvmrc`_ for details.

**Gemfile, Gemfile.lock**
   describes the gem dependencies required to execute associated Ruby code.
   Required and updated automatically by `Bundler`_.

**Rakefile**
   global `rake`_ configuration file. Simply loads all tasks from the tasks/
   folder.

**ca/**
   This directory contains an OpenSSL Certificate Authority. It is managed with
   `rake`_ tasks and provides seamless deployments of inter-node trust and
   public SSL certificates on chef nodes. See :ref:`chef-ca` for details.

**config/**
   Miscellaneous configuration files for Chef, OpenSSL and others.

**cookbooks/**
   This directory contains all public cookbooks and recipes. See
   :ref:`chef-cookbooks` for details.

**databags/**
   This directory contains site-specific databags (simple JSON dictionaries
   uploaded to the Chef server). See :ref:`chef-databags` for details.

**documentation/**
   Contains the source code for the documentation you are currently reading.

**nodes/**
   Contains one file per node that is managed with chef. This list of nodes is
   uploaded to the Chef server via rake. See :ref:`chef-nodes` for details.

**roles/**
   Contains roles that can be applied to nodes. A role is simply a list of
   recipes and attributes that can be applied to multiple nodes without
   copy&paste. See :ref:`chef-roles` for details.

**scripts/**
   A collection of scripts that can be used together with specific rake tasks
   for daily administration tasks.

**site-cookbooks/**
   This directory contains site-specific cookbooks and recipes. This is the
   place where you can add recipes specific to your infrastructure. See
   :ref:`chef-cookbooks` for details.

**tasks/**
   Contains all available rake tasks. See :ref:`chef-tasks` for details.


.. _RVM: https://rvm.beginrescueend.com/
.. _Bundler: http://gembundler.com/
.. _rake: http://rake.rubyforge.org/
.. _Project .rvmrc: https://rvm.beginrescueend.com/workflow/rvmrc/#project
