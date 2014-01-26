Getting Started
===============

Chef is a systems and infrastructure automation framework that makes it
easy to deploy servers and applications to any physical, virtual, or cloud
location, no matter the size of the infrastructure.

Chef is based on a key insight: You can model your evolving IT infrastructure
and applications as code. Chef makes no assumptions about your environment and
the approach you use to configure and manage it. Instead, Chef gives you a way
to describe and automate your infrastructure and processes. Your infrastructure
becomes testable, versioned and repeatable. It becomes part of your Agile
process.

Chef relies on reusable definitions known as cookbooks and recipes that are
written using the the Ruby programming language. Cookbooks and recipes automate
common infrastructure tasks. Their definitions describe what your
infrastructure consists of and how each part of your infrastructure should be
deployed, configured and managed. Chef applies those definitions to
workstations and servers to produce an automated infrastructure.

This repository contains all public cookbooks from ZenOps. Additionally various
scripts, rake tasks and documentation is available.

Usage
-----

The repository uses RVM and Bundler to manage ruby and dependencies required by
Chef. To start your own copy of this repository clone the repository first and
bootstrap your local rvm environment::

  git clone https://github.com/zenops/cookbooks chef && cd chef
  ./scripts/bootstrap

Next: :doc:`Setup your workstation </workstation>`
