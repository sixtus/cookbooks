ZenOps Chef Cookbooks
=====================

This repository contains all public cookbooks from ZenOps. Additionally various
scripts, rake tasks and documentation is available.

Usage
-----

The repository uses RVM and Bundler to manage ruby and dependencies required by
Chef. To start your own copy of this repository clone the repository first and
bootstrap your local rvm environment::

  git clone https://github.com/zenops/cookbooks chef && cd chef
  ./scripts/bootstrap

Repository Layout
-----------------

This repository contains several directories, and each directory contains a
README file that describes what it is for in greater detail, and how to use it
for managing your systems with Chef.

**ca**
   This directory contains an OpenSSL Certificate Authority. It is managed with
   rake tasks and provides seamless deployments of inter-node trust and public
   SSL certificates on chef nodes.

**config**
   Miscellaneous configuration files for Chef, OpenSSL and others.

**cookbooks**
   This directory contains all public cookbooks and recipes.

**databags**
   This directory contains site-specific databags (simple JSON dictionaries
   uploaded to the Chef server).

**nodes**
   Contains one file per node that is managed with chef.

**roles**
   Contains roles that can be applied to nodes.

**scripts**
   A collection of scripts that can be used for daily administration tasks.

**site-cookbooks**
   This directory contains site-specific cookbooks and recipes. This is the
   place where you can add recipes specific to your infrastructure.

**tasks**
   Contains all available rake tasks.

External Resources
------------------

* `Chef Wiki <http://wiki.opscode.com/display/chef/Home>`_
