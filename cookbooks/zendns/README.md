Usage
=====

The ZenDNS cookbook -- together with `role[zendns]` -- installs and configures
a DNS cluster based on PowerDNS and MongoDB. The [ZenDNS management
interface](https://github.com/zenops/zendns) needs to be deployed seperately.

You need to create a SSH key pair for the web interface and give that read-only
access to your repository:

  ssh-keygen -f cookbooks/zendns/files/default/id_rsa -C zendns -N ''

Attributes
==========

 * `zendns[:server_name] = node[:fqdn]`

   The canonical server name for the ZenDNS management web interface.

 * `zendns[:ssl][:cn] = node[:fqdn]`

   The SSL certificate common name for the web interface.

 * `zendns[:deployers] = []`

   A list of symbols matching user accounts that will have deploy access to the
   web interface.
