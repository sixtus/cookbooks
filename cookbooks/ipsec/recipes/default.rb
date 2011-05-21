tag("ipsec")

include_recipe "openssl"

package "net-firewall/ipsec-tools"

nodes = node.run_state[:nodes].select do |n|
  n[:tags].include?("ipsec") and
  n[:ipv6_enabled] == true and
  n[:fqdn] != node[:fqdn]
end

template "/etc/ipsec.conf" do
  source "ipsec.conf.erb"
  owner "root"
  group "root"
  mode "0640"
  variables :nodes => nodes
  notifies :restart, "service[racoon]"
end

directory "/etc/ssl/racoon" do
  owner "root"
  group "root"
  mode "0750"
  recursive true
end

ssl_ca "/etc/ssl/racoon/ca" do
  symlink true
  notifies :restart, "service[racoon]"
end

ssl_certificate "/etc/ssl/racoon/machine" do
  cn node[:fqdn]
  notifies :restart, "service[racoon]"
end

directory "/etc/racoon" do
  owner "root"
  group "root"
  mode "0750"
end

template "/etc/racoon/racoon.conf" do
  source "racoon.conf.erb"
  owner "root"
  group "root"
  mode "0640"
  variables :nodes => nodes
  notifies :restart, "service[racoon]"
end

cookbook_file "/etc/conf.d/racoon" do
  source "racoon.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[racoon]"
end

service "racoon" do
  action [:enable, :start]
end
