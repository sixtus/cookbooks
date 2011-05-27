package "app-admin/chef"

directory "/var/lib/chef/cache" do
  group "root"
  mode "0750"
end

template "/etc/chef/client.rb" do
  source "client.rb.erb"
  owner "root"
  group "root"
  mode "0644"
end

service "chef-client" do
  action [:disable, :stop]
end

cookbook_file "/etc/logrotate.d/chef" do
  source "chef.logrotate"
  owner "root"
  group "root"
  mode "0644"
end

file "/var/log/chef/client.log" do
  owner "root"
  group "root"
  mode "0600"
end
