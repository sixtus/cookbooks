Roles
=====

A role provides a means of grouping similar features of similar nodes,
providing a mechanism for easily composing sets of functionality. At web scale,
you almost never have just one of something, so you use roles to express the
parts of the configuration that are shared by a group of nodes.

 * Roles consist of the same parts as a node: Attributes and a Run List.
 * Nodes can have multiple roles applied, and they will be expanded in place,
   providing for a complete recipe list for that node.
 * When the Chef client runs, it merges its own attributes and run list with
   those of any roles it has been assigned.

Role Files
----------

The roles run list and attributes can be managed with Ruby files in the ``roles``
directory of the Chef repository. There should be one file per role and the
filename must be equal to the role name (``<role>.rb``).

Role attributes can be specified with the ``default_attributes`` and
``override_attributes`` methods.

The run list can be specified with the ``run_list`` method. A simple node file
might look similar to the following::

  run_list(%w(
    recipe[base]
    recipe[cron]
    recipe[syslog]
  ))

Managing Roles
--------------

Roles can be managed with one of the provided ``rake`` tasks or the ``knife``
command line client:

**Upload single role**
  ``rake load:role[base]``

**Upload all roles**
  ``rake load:roles``

**Listing all roles**
  ``knife role list``

**Deleting a role**
  ``knife role delete foo``

.. note::
   Roles should not be edited or created with the knife command line client.
   The purpose of the Chef repository is to be the single **authoritative**
   source of information for the infrastructure. Always edit the role files and
   upload via ``rake load:roles``.

External Resources
------------------

 * http://wiki.opscode.com/display/chef/Roles
