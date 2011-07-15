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
    rescue Bunny::ProtocolError
      true
    end
  end
end

# install chef-server
package "app-admin/chef-server"

template "/etc/chef/solr.rb" do
  source "solr.rb.erb"
  owner "chef"
  group "chef"
  mode "0600"
  notifies :restart, "service[chef-solr]"
  variables :amqp_pass => amqp_pass
end

template "/etc/conf.d/chef-server-api" do
  source "chef-server-api.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[chef-server-api]"
end

template "/etc/chef/server.rb" do
  source "server.rb.erb"
  owner "chef"
  group "chef"
  mode "0600"
  notifies :restart, "service[chef-server-api]"
  variables :amqp_pass => amqp_pass
end

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

execute "chef-solr-installer" do
  command "chef-solr-installer -c /etc/chef/solr.rb -u chef -g chef -f"
  only_if "echo '2e275746307c89bcf2f18671da2d4f3d /var/lib/chef/solr/jetty/webapps/solr.war' | md5sum -c --quiet"
end

%w(
  chef-server-api
  chef-solr
).each do |s|
  service s do
    action [:enable, :start]
  end
end

# documentation
package "dev-python/sphinx"

remote_directory "/var/www/documentation" do
  source "documentation/html"
  files_backup 0
  files_owner "root"
  files_group "root"
  files_mode "0644"
  owner "root"
  group "root"
  mode "0755"
end

users = node.run_state[:users].select do |u|
  u[:tags] and
  u[:tags].include?("hostmaster") and
  u[:password]
end

template "/var/www/documentation/.htpasswd" do
  source "htpasswd"
  owner "root"
  group "nginx"
  mode "0640"
  variables :users => users
end

# nginx SSL proxy
ssl_ca "/etc/ssl/nginx/#{node[:fqdn]}-ca"

ssl_certificate "/etc/ssl/nginx/#{node[:fqdn]}" do
  cn node[:fqdn]
end

%w(
  modules/passenger.conf
  servers/chef-server-webui.conf
).each do |f|
  file "/etc/nginx/#{f}" do
    action :delete
  end
end

nginx_server "chef-server-api" do
  template "chef-server-api.nginx.erb"
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
nrpe_command "check_chef_server_ssl" do
  command "/usr/lib/nagios/plugins/check_ssl_cert -H localhost -n #{node[:fqdn]} -p 443 -r /etc/ssl/nginx/#{node[:fqdn]}-ca.crt -w 21 -c 7"
end

nrpe_command "check_chef_solr" do
  command "/usr/lib/nagios/plugins/check_pidfile /var/run/chef/solr.pid"
end

nrpe_command "check_chef_expander" do
  command "/usr/lib/nagios/plugins/check_pidfile /var/run/chef/expander.pid"
end

nagios_service "CHEF-SERVER" do
  check_command "check_chef_server"
  servicegroups "chef"
end

nagios_service "CHEF-SERVER-SSL" do
  check_command "check_nrpe!check_chef_server_ssl"
  servicegroups "chef"
end

nagios_service "CHEF-SOLR" do
  check_command "check_nrpe!check_chef_solr"
  servicegroups "chef"
end

nagios_service "CHEF-EXPANDER" do
  check_command "check_nrpe!check_chef_expander"
  servicegroups "chef"
end
