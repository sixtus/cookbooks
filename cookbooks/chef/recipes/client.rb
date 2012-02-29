package "app-admin/chef"

if node[:chef][:client][:airbrake][:key]
  package "dev-ruby/airbrake_handler"
end

directory "/var/log/chef" do
  owner "chef"
  group "chef"
  mode "0755"
end

directory "/var/lib/chef/cache" do
  group "root"
  mode "0750"
end

unless solo?
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
end
