.. _chef-cookbooks:

Cookbooks
=========

Cookbooks are the fundamental units of distribution in Chef. They encapsulate
all the resources you need to automate your infrastructure and are easily
sharable with other Chef users.

Cookbooks contain:

 * `Attributes <http://wiki.opscode.com/display/chef/Attributes>`_ that are
   values on a :ref:`Node <chef-nodes>` to set default values used elsewhere in
   the cookbook.

 * `Definitions <http://wiki.opscode.com/display/chef/Definitions>`_ that allow
   you to create reusable collections of one or more `Resources
   <http://wiki.opscode.com/display/chef/Resources>`_.

 * `File Distribution
   <http://wiki.opscode.com/display/chef/File+Distribution>`_ that are
   transferred to your nodes via the ``cookbook_file`` resource.

 * `Libraries <http://wiki.opscode.com/display/chef/Libraries>`_ that extend
   Chef or provide helpers with Ruby code.

 * `Recipes <http://wiki.opscode.com/display/chef/Recipes>`_ that specify
   `Resources <http://wiki.opscode.com/display/chef/Resources>`_ to manage, in
   the order they should be managed.

 * `Lightweight Resources and Providers (LWRP)
   <http://wiki.opscode.com/display/chef/Lightweight+Resources+and+Providers+%28LWRP%29>`_
   that allow you to create your own custom resources and providers.

 * `Templates <http://wiki.opscode.com/display/chef/Templates>`_ that are
   rendered on Chef-configured machines with your dynamically substituted
   values. Think config files on steroids, then read `ERB templates
   <http://wiki.opscode.com/display/chef/Resources#Resources-Template>`_.

 * `Metadata <http://wiki.opscode.com/display/chef/Metadata>`_ that tells Chef
   about your recipes, including dependencies, supported platforms and more.

Each of these components is a directory or file. An example cookbook directory
after might look like::

  attributes/
  definitions/
  files/
  libraries/
  metadata.rb
  providers/
  README.rst
  recipes/
  resources/
  templates/

However, most of the time, only recipes, attributes, files and templates are
used. Definitions, resources and providers need to be implemented on rare
occassions to simplify recipes or support custom software.

You develop cookbooks on your local system in the :ref:`Chef repository
<chef-repository>`, in the ``cookbooks`` or ``site-cookbooks`` sub-directory.

List of Cookbooks
-----------------

.. toctree::
   :glob:
   :maxdepth: 1

   *
