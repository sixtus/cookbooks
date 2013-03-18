package "app-admin/chef"
package "dev-ruby/syslogger"
package "dev-ruby/madvertise-logging"

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

  cron "chef-client" do
    command "/usr/bin/ruby19 -E UTF-8 /usr/bin/chef-client -c /etc/chef/client.rb &>/dev/null"
    minute IPAddr.new(node[:primary_ipaddress]).to_i % 60
    action :delete unless node.chef_environment == 'production'
    action :delete if systemd_running?
  end

  systemd_unit "chef-client.service"
  systemd_unit "chef-client.timer"

  service "chef-client.timer" do
    action [:enable, :start]
    only_if { systemd_running? }
  end

  # chef-client.service has a condition on this lock
  # so we use it to stop chef-client on testing/staging machines
  file "/run/lock/chef-client.lock" do
    action :delete if node.chef_environment == 'production'
  end

  splunk_input "monitor:///var/log/chef/*.log"

  cookbook_file "/etc/logrotate.d/chef" do
    source "chef.logrotate"
    owner "root"
    group "root"
    mode "0644"
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
