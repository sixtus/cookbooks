package "app-admin/chef" do
  action :upgrade
  notifies :restart, "service[chef-client]"
end

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
    action [:enable, :start]
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

if tagged?("nagios-client")
  nrpe_command "check_chef_client" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/chef/client.pid"
  end

  nagios_service "CHEF-CLIENT" do
    check_command "check_nrpe!check_chef_client"
    servicegroups "chef"
  end
end
