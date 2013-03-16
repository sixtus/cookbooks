tag("chef-server")

include_recipe "chef::client"
include_recipe "couchdb"
include_recipe "java"
include_recipe "nginx"
include_recipe "openssl"
include_recipe "rabbitmq"

# setup RabbitMQ user/permissions
amqp_pass = get_password("rabbitmq/chef")

execute "rabbitmqctl add_vhost /chef" do
  not_if "rabbitmqctl list_vhosts | grep /chef"
end

execute "rabbitmqctl add_user chef chef" do
  not_if "rabbitmqctl list_users | grep chef"
end

execute "rabbitmqctl set_permissions -p /chef chef '.*' '.*' '.*'" do
  not_if "rabbitmqctl list_user_permissions chef | grep /chef"
end

execute "rabbitmqctl change_password chef" do
  command "rabbitmqctl change_password chef #{amqp_pass}"
  only_if do
    begin
      b = Bunny.new({
        :spec   => '08',
        :host   => Chef::Config[:amqp_host],
        :port   => Chef::Config[:amqp_port],
        :vhost  => Chef::Config[:amqp_vhost],
        :user   => Chef::Config[:amqp_user],
        :pass   => amqp_pass,
      })
      b.start
      b.stop
      false
    rescue Bunny::ProtocolError, Errno::ECONNRESET
      true
    end
  end
end

# install chef-server
package "app-admin/chef-server"

directory "/root/.chef" do
  owner "root"
  group "root"
  mode "0700"
end

template "/root/.chef/knife.rb" do
  source "knife.rb"
  owner "root"
  group "root"
  mode "0600"
end

directory "/etc/chef/certificates" do
  owner "chef"
  group "root"
  mode "0700"
end

directory "/var/lib/chef" do
  owner "chef"
  group "chef"
  mode "0750"
end

%w(
  backup
  checksums
  sandboxes
).each do |d|
  directory "/var/lib/chef/#{d}" do
    owner "chef"
    group "root"
    mode "0750"
  end
end

template "/etc/chef/solr.rb" do
  source "solr.rb"
  owner "chef"
  group "chef"
  mode "0600"
  notifies :restart, "service[chef-solr]"
  variables :amqp_pass => amqp_pass
end

execute "chef-solr-installer" do
  command "chef-solr-installer -c /etc/chef/solr.rb -u chef -g chef -f"
  creates "/var/lib/chef/solr/jetty"
end

execute "wait-for-chef-solr" do
  command "while ! netstat -tulpen | grep -q 8983; do sleep 1; done"
  action :nothing
end

systemd_unit "chef-solr.service"

service "chef-solr" do
  action [:start, :enable]
  notifies :run, "execute[wait-for-chef-solr]", :immediately
end

systemd_unit "chef-expander.service"

service "chef-expander" do
  action [:start, :enable]
end

template "/etc/conf.d/chef-server-api" do
  source "chef-server-api.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[chef-server-api]"
end

template "/etc/chef/server.rb" do
  source "server.rb"
  owner "chef"
  group "chef"
  mode "0600"
  notifies :restart, "service[chef-server-api]", :immediately
  variables :amqp_pass => amqp_pass
end

systemd_unit "chef-server-api.service"

service "chef-server-api" do
  action [:start, :enable]
end

# nginx SSL proxy
ssl_ca "/etc/ssl/nginx/#{node[:fqdn]}-ca" do
  notifies :reload, "service[nginx]"
end

ssl_certificate "/etc/ssl/nginx/#{node[:fqdn]}" do
  cn node[:fqdn]
  notifies :reload, "service[nginx]"
end

nginx_server "chef-server-api" do
  template "nginx.conf"
end

# CouchDB maintenance
require 'open-uri'

http_request "compact chef couchDB" do
  action :post
  url "#{Chef::Config[:couchdb_url]}/chef/_compact"
  only_if do
    disk_size = 0

    begin
      f = open("#{Chef::Config[:couchdb_url]}/chef")
      disk_size = JSON::parse(f.read)["disk_size"]
      f.close
    rescue ::OpenURI::HTTPError
      nil
    end

    disk_size > 100_000_000
  end
end

%w(
  clients
  cookbooks
  data_bags
  id_map
  nodes
  roles
  sandboxes
  users
).each do |view|
  http_request "compact chef couchDB view #{view}" do
    action :post
    url "#{Chef::Config[:couchdb_url]}/chef/_compact/#{view}"
    only_if do
      disk_size = 0

      begin
        f = open("#{Chef::Config[:couchdb_url]}/chef/_design/#{view}/_info")
        disk_size = JSON::parse(f.read)["view_index"]["disk_size"]
        f.close
      rescue ::OpenURI::HTTPError
        nil
      end

      disk_size > 100_000_000
    end
  end
end

# nagios service checks
if tagged?("nagios-client")
  nagios_service "CHEF-SERVER" do
    check_command "check_http!-S -s 'This is the Chef API Server.'"
    servicegroups "chef"
  end

  nagios_service "CHEF-SERVER-SSL" do
    check_command "check_http!-S -C 21"
    servicegroups "chef"
  end

  nrpe_command "check_chef_solr" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/chef/solr.pid"
  end

  nagios_service "CHEF-SOLR" do
    check_command "check_nrpe!check_chef_solr"
    servicegroups "chef"
  end

  nrpe_command "check_chef_expander" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/chef/expander.pid"
  end

  nagios_service "CHEF-EXPANDER" do
    check_command "check_nrpe!check_chef_expander"
    servicegroups "chef"
  end
end
