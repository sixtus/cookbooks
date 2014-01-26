ZenOps Chef Cookbooks
=====================

This repository contains all public cookbooks from ZenOps.

Read the `documentation <http://zenops.rtfd.org>`.

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

