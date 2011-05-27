package "app-admin/chef"

directory "/var/lib/chef/cache" do
  group "root"
  mode "0750"
end

directory "/root/.chef" do
  owner "root"
  group "root"
  mode "0700"
end

%w(
  /etc/chef/client.rb
  /root/.chef/knife.rb
).each do |f|
  template f do
    source "client.rb.erb"
    owner "root"
    group "root"
    mode "0644"
  end
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
