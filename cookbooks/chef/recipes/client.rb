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
    source "client.rb"
    owner "root"
    group "root"
    mode "0644"
  end

  service "chef-client" do
    action [:disable, :stop]
  end

  # distribute chef-client runs randomly
  chef_minute = IPAddr.new(node[:primary_ipaddress]).to_i % 60

  # and only converge automatically in production
  if node.chef_environment == 'production'
    chef_action = :create
  else
    chef_action = :delete
  end

  cron "chef-client" do
    command "/usr/bin/ruby19 -E UTF-8 /usr/bin/chef-client -c /etc/chef/client.rb >/dev/null"
    minute chef_minute
    action chef_action
  end

  splunk_input "monitor:///var/log/chef/*.log"

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

  directory "/etc/chef/cache" do
    action :delete
    recursive true
    only_if { File.directory?("/etc/chef/cache") and not File.symlink?("/etc/chef/cache") }
  end

  link "/etc/chef/cache" do
    to "/var/lib/chef/cache"
  end
end
