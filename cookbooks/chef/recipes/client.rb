if gentoo?
  package "app-admin/chef"

  directory "/etc/chef" do
    owner "chef"
    group "root"
    mode "0755"
  end

  directory "/var/log/chef" do
    owner "chef"
    group "chef"
    mode "0755"
  end

  directory "/var/lib/chef/cache" do
    owner "chef"
    group "root"
    mode "0750"
  end
elsif debian_based?
  gem_package "chef"

  directory "/etc/chef" do
    owner "root"
    group "root"
    mode "0755"
  end

  directory "/var/log/chef" do
    owner "root"
    group "root"
    mode "0755"
  end

  directory "/var/lib/chef" do
    owner "root"
    group "root"
    mode "0750"
  end

  directory "/var/lib/chef/cache" do
    owner "root"
    group "root"
    mode "0750"
  end
end

unless solo?
  file "/etc/chef/client.pem" do
    owner "root"
    group "root"
    mode "0400"
  end

  template "/etc/chef/client.rb" do
    source "client.rb"
    owner "root"
    group "root"
    mode "0644"
  end

  template "/etc/chef/knife.rb" do
    source "client.rb"
    owner "root"
    group "root"
    mode "0644"
  end

  timer_envs = %w(production staging)

  nodes = chef_client_nodes.map do |n|
    n[:fqdn]
  end

  minutes = nodes.each_with_index.map do |_, idx|
    (idx * (60.0 / nodes.length)).to_i
  end

  index = nodes.index(node[:fqdn])
  minute = minutes[index] rescue 0

  cron "chef-client" do
    command "/usr/bin/ruby -E UTF-8 #{node[:chef][:binary]} -c /etc/chef/client.rb &>/dev/null"
    minute minute
    action :delete unless timer_envs.include?(node.chef_environment)
    action :delete if systemd_running?
  end

  systemd_unit "chef-client.service"

  systemd_timer "chef-client" do
    schedule [
      "OnBoot=60",
      "OnCalendar=*:#{minute}",
    ]
  end

  # chef-client.service has a condition on this lock
  # so we use it to stop chef-client on testing/staging machines
  file "/run/lock/chef-client.lock" do
    action :delete if timer_envs.include?(node.chef_environment)
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
