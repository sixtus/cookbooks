Nodes
=====

A node is a host that runs the Chef client. A node is made up of two prime
components: a list of Recipes or Roles to run (in the order you want them run)
called a Run List, and Attributes. Recipes are the fundamental building block
of Chef - they define the resources you want managed, in the order you want
them managed. Attributes are data about your node - things like the network
interfaces, file systems, or how many clients your Apache server can accept.

Authentication
--------------

Chef uses Signed Header Authentication for each request. Node data is separate
from the identity used to authenticate requests to the Chef server, which is
managed by an API client. Each API client has a public/private key pair. The
public half of the key is stored in the database on the server, and the private
half is kept locally by the client. On a node running the Chef client, the
private key is generally stored in /etc/chef/client.pem. Each request to the
Chef server includes a request signature in the HTTP headers. The request
signature is computed from the hash of the request content and encrypted with
the client's private key to verify the identity of the user or machine making
the request and prevent attempts to tamper with the content.

For more information about the authentication mechanism, refer to the
`Authentication <http://wiki.opscode.com/display/chef/Authentication>`_
documentation.

Lifecycle of a Node
-------------------

When you start the Chef client, the first thing it does is create a Node
object. It then loads up Ohai, a library which detects information about the
operating system (hostname, network interfaces etc). Based on the hosts fully
qualified domain name and hostname, the last known state of the Node is pulled
from the Chef server. Once there, all the Ohai attributes are updated to their
latest value and all all of the attribute files in all of the cookbooks in your
Chef repository are run.

Node Files
----------

The nodes run list and attributes can be managed with Ruby files in the ``nodes``
directory of the Chef repository. There should be one file per node and the
filename must be equal to the nodes fully qualified hostname (``<fqdn>.rb``).

Node attributes can be specified with the ``default``, ``set`` or ``override``
methods.

The run list can be specified with the ``run_list`` method. A simple node file
might look similar to the following::

  run_list(%w(
    role[base]
  ))

Managing Nodes
--------------

Roles can be managed with one of the provided ``rake`` tasks or the ``knife``
command line client:

**Upload single node**
  ``rake load:node[my.example.com]``

**Upload all nodes**
  ``rake load:nodes``

**Listing all nodes**
  ``knife node list``

.. note::
   Nodes should normally not be edited or created with the knife command line client.
   The purpose of the Chef repository is to be the single **authoritative**
   source of information for the infrastructure. Always edit the node files and
   upload via ``rake load:nodes``.

   There is, however, an exception to this rule: Sometimes attributes that have
   been set previously with the ``set`` or ``override`` methods need to be
   deleted. In This case ``knife node edit my.example.com`` will allow editing
   the nodes JSON source directly.

External Resources
------------------

 * http://wiki.opscode.com/display/chef/Nodes
