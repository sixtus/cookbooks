template "/etc/env.d/99splunk" do
  source "99splunk"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, 'execute[env-update]'
end

directory "/etc/ssl/splunk" do
  owner "root"
  group "root"
  mode "0750"
end

ssl_ca "/etc/ssl/splunk/ca"

ssl_certificate "/etc/ssl/splunk/server" do
  cn node[:fqdn]
  notifies :restart, "service[splunk]"
end

template "/opt/splunk/etc/system/default/server.conf" do
  source "server.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[splunk]"
end

directory "/opt/splunk/etc/system/local" do
  owner "root"
  group "root"
  mode "0755"
end

%w(
  inputs
  prefs
  web
).each do |c|
  template "/opt/splunk/etc/system/local/#{c}.conf" do
    source "#{c}.conf"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[splunk]"
  end
end

template "/opt/splunk/bin/scripts/hipchat-alert.rb" do
  source "hipchat-alert.rb"
  owner "root"
  group "root"
  mode "0750"
  only_if { node[:hipchat] and node[:hipchat][:auth_token] }
end

cookbook_file "/etc/init.d/splunk" do
  source "splunk.initd"
  owner "root"
  group "root"
  mode "0755"
end

systemd_unit "splunk.service"

service "splunk" do
  action [:enable, :start]
end

include_recipe "splunk::systemd"

if tagged?("nagios-client")
  nrpe_command "check_splunkd" do
    command "/usr/lib/nagios/plugins/check_pidfile /opt/splunk/var/run/splunk/splunkd.pid splunkd"
  end

  nagios_service "SPLUNKD" do
    check_command "check_nrpe!check_splunkd"
    env [:testing, :development]
  end
end
