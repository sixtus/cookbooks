Cooking with Chef
=================

Chef is a fully functional configuration management tool. Roles and Recipes are
used to describe how servers should be configured. Chef works by allowing you
to write recipes that describe what roles a server (such as Apache, MySQL, or
MongoDB) should be configured as. These recipes describe a series of resources
that should be in a particular state - for example, packages that should be
installed, services that should be running, or files that should be written.
Chef then makes sure that each resource is properly configured, only taking
corrective action when it's necessary. The result is a safe, flexible mechanism
for making sure your servers are always running exactly how you want them to
be.

Provisioning
------------

Chef invokes system and API calls to automate the provisioning of servers
through RESTful API calls or through the command line interface ``knife``. Chef
also integrates with Gentoo Linux to bootstrap the Chef server and clients on
newly provisioned systems.

Systems Integration
-------------------

One of the most powerful features of Chef is in its design of separating the
configuration data from configuration logic. Data about your infrastructure is
dynamically stored and indexed in a NoSQL database and a powerful search API is
provided to query information about your infrastructure and applications. In
other words Chef recipes can be data driven thereby providing dynamic system
integration between servers. For example, when configuring a web server the
search API can be called to discover the database and memcache servers and then
automatically update the web server’s configuration. Likewise a load balancer
recipe can automatically add the web servers into its configuration.

Core Principles
---------------

Chef is based on a few core principles which should always be kept in mind in
order to not "work against the system".

**Chef is idempotent**
  What this means is that you can run Chef recipes multiple times on the same
  system and the resulting system will always return to an identical state. In
  Chef, resources are defined in recipes. The resources describe actions to be
  performed on the system. Chef ensures that actions are not performed if the
  resources have not changed. This means that if you rerun a Chef recipe on a
  system and nothing has changed either on the system or in the recipe Chef
  doesn't change anything.

**Order Matters**
  When you are configuring systems, order matters. If you have not installed
  Apache, you can’t start configuring it, and you certainly can’t start the
  daemon. Configuration management tools have been struggling with this problem
  for years. Nodes in Chef apply lists of recipes, which in turn specify
  resources. Within a recipe, resources are applied in the order they appear.
  At any point in a recipe, you can include any other recipe - assuring that
  all of its resources are applied before continuing (Chef is smart enough
  never to apply the same recipe twice.) You specify dependencies only at the
  recipe level, not the resource level. This means that you only track
  dependencies between high level concepts - "I need Apache installed before I
  can start my Django Application". It also means that, given the same set of
  Cookbooks, Chef will always execute your resources in the same order.

**Reasonability**
  Chef is designed to be easy to think about, easily changed and easy to
  extend. Chef assumes that you know best how your infrastructure is put
  together. Therefore, Chef makes as few decisions for you as possible, and
  when it does, it’s easy to make it change its mind. When Chef does make
  decisions it sets reasonable defaults that can be easily changed. Moreover,
  Chef is pragmatic and opinion-less relying less on theory or dogma and more
  on deterministic results. This is why Chef uses Ruby as its reference
  language with extended DSL for specific resources. Chef provides a reasonable
  set of base primitives (i.e., resources) to automate an infrastructure;
  however, it also provides an easy way to modify and extend the base (via
  Ruby)

**Thick Clients, Thin Server**
  Chef does as much work as possible on the Chef Clients. The Chef Server is
  built to handle the easy distribution of data to the clients - the recipes to
  build, templates to render, files to transfer - along with storing the state
  of each Node. This orientation makes for a system that is easy to scale and
  extend - the work of deciding how to configure your infrastructure is
  distributed throughout your infrastructure, rather than centralized on set of
  configuration management servers.

Contents
--------

This chapter will explain Chef from a top-down perspective. First the Chef
repository layout and its generic parts are explained. Then, starting from the
high-level concept of a node we will make our way down to recipes, resources,
attributes and libraries.

.. toctree::
   :maxdepth: 1

   repository
   nodes
   roles
   databags
