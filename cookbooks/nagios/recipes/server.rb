tag("nagios-master")

include_recipe "apache::php"

portage_package_use "net-analyzer/nagios-core" do
  use %w(apache2)
end

portage_package_use "net-analyzer/nagios-plugins" do
  use %w(ldap mysql nagios-dns nagios-ntp nagios-ping nagios-ssh postgres)
end

include_recipe "nagios::nrpe"
include_recipe "nagios::nsca"

package "net-analyzer/nagios"

directory "/etc/nagios" do
  owner "nagios"
  group "nagios"
  mode "0750"
end

directory "/var/nagios/rw" do
  owner "nagios"
  group "apache"
  mode "6755"
end

file "/var/nagios/rw/nagios.cmd" do
  owner "nagios"
  group "apache"
  mode "0660"
end

directory "/var/run/nsca" do
  owner "nagios"
  group "nagios"
  mode "0755"
end

template "/usr/lib/nagios/plugins/notify" do
  source "notify"
  owner "root"
  group "nagios"
  mode "0750"
end

# nagios master/slave setup
slave = node.run_state[:nodes].select do |n|
  n[:tags].include?("nagios-master") and
  n[:fqdn] != node[:fqdn]
end

if slave.length > 1
  raise "only 1 nagios slave is supported. found: #{slave.map { |n| n[:fqdn] }.inspect}"
else
  slave = slave.first
end

if slave
  include_recipe "beanstalkd"

  nagios_plugin "queue_check_result"
  nagios_plugin "process_check_results"

  cookbook_file "/etc/init.d/nsca-processor" do
    source "nsca-processor.initd"
    owner "root"
    group "root"
    mode "0755"
  end

  template "/etc/conf.d/nsca-processor" do
    source "nsca-processor.confd"
    owner "root"
    group "root"
    mode "0644"
    variables :slave => slave
  end

  service "nsca-processor" do
    action [:enable, :start]
  end

  nrpe_command "check_beanstalkd_nsca" do
    command "/usr/lib/nagios/plugins/check_beanstalkd -S localhost:11300 " +
            "-w #{node[:beanstalkd][:nagios][:warning]} " +
            "-c #{node[:beanstalkd][:nagios][:critical]} " +
            "-t send_nsca"
  end

  nagios_service "BEANSTALKD-NSCA" do
    check_command "check_nrpe!check_beanstalkd_nsca"
  end

  nagios_plugin "enable_master"
  nagios_plugin "disable_master"

  template "/usr/lib/nagios/plugins/check_nagios_slave" do
    source "check_nagios_slave"
    owner "root"
    group "nagios"
    mode "0750"
    variables :slave => slave
  end

  cron "check_nagios_slave" do
    command "/usr/bin/flock /var/lock/check_nagios_slave.lock -c /usr/lib/nagios/plugins/check_nagios_slave"
  end
end

# retrieve data from the search index
contacts = search(:users, "nagios_contact_groups:[* TO *]").sort { |a,b| a[:id] <=> b[:id] }
hostmasters = search(:users, "nagios_contact_groups:hostmasters").sort { |a,b| a[:id] <=> b[:id] }

hosts = node.run_state[:nodes].select do |n|
  n[:tags].include?("nagios-client")
end.sort do |a,b|
  a[:fqdn] <=> b[:fqdn]
end

roles = search(:role, "NOT name:base").sort { |a,b| a.name <=> b.name }
hostgroups = {}

roles.each do |role|
  hostgroups[role.name] = []
end

hosts.each do |host|
  cluster = host[:cluster][:name] or "default"

  hostgroups[cluster] ||= []
  hostgroups[cluster] << host[:fqdn]

  host[:roles] ||= []
  host[:roles].each do |role|
    hostgroups[role] ||= []
    hostgroups[role] << host[:fqdn] unless role == "base"
  end
end

servicegroups = []
hosts.each do |host|
  host[:nagios][:services].each do |name, params|
    if params[:servicegroups]
      servicegroups |= params[:servicegroups].split(",")
    end
  end
end

# remove sample objects
%w(hosts localhost printer services switch windows).each do |f|
  nagios_conf f do
    action :delete
  end
end

# nagios base config
%w(nagios nsca resource).each do |f|
  nagios_conf f do
    subdir false
    variables :slave => slave
  end
end

nagios_conf "cgi" do
  subdir false
  variables :hostmasters => hostmasters
end

# create nagios objects
%w(templates commands).each do |f|
  nagios_conf f
end

nagios_conf "contacts" do
  variables :contacts => contacts
end

nagios_conf "timeperiods" do
  variables :contacts => contacts
end

nagios_conf "hostgroups" do
  variables :hostgroups => hostgroups
end

nagios_conf "servicegroups" do
  variables :servicegroups => servicegroups
end

hosts.each do |host|
  nagios_conf "host-#{host[:fqdn]}" do
    template "host.cfg.erb"
    variables :host => host
  end
end

include_recipe "nagios::extras"

service "nagios" do
  action [:enable, :start]
end

service "nsca" do
  action [:enable, :start]
end

# apache specifics
group "nagios" do
  members %w(apache)
  append true
end

users = search(:users, "nagios_contact_groups:[* TO *] AND password:[* TO *]", "id asc")

template "/etc/nagios/users" do
  source "users.erb"
  owner "root"
  group "apache"
  mode "0640"
  variables :users => users
end

node[:apache][:default_redirect] = "https://#{node[:fqdn]}"

ssl_ca "/etc/ssl/apache2/ca"

ssl_certificate "/etc/ssl/apache2/server" do
  cn node[:fqdn]
end

apache_vhost "nagios" do
  template "nagios.vhost.conf.erb"
end

file "/var/www/localhost/htdocs/index.php" do
  content '<?php header("Location: /nagios/"); ?>\n'
  owner "root"
  group "root"
  mode "0644"
end

file "/var/www/localhost/htdocs/index.html" do
  action :delete
end

template "/usr/share/nagios/htdocs/index.php" do
  source "index.php"
  owner "root"
  group "root"
  mode "0644"
end

nrpe_command "check_nagios" do
  command "/usr/lib/nagios/plugins/check_nagios -F /var/nagios/status.dat -C /usr/sbin/nagios -e 5"
end

nagios_service "NAGIOS" do
  check_command "check_nrpe!check_nagios"
end
