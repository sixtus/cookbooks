directory "/etc/ssl/splunk" do
  owner "root"
  group "root"
  mode "0750"
end

ssl_ca "/etc/ssl/splunk/ca" do
  notifies :restart, "service[splunk]"
end

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

execute "stop-splunk" do
  command "/opt/splunk/bin/splunk stop"
  action :nothing
end

execute "start-splunk-first-time" do
  command "/opt/splunk/bin/splunk start --accept-license"
  creates "/opt/splunk/etc/auth/splunk.secret"
  notifies :run, "execute[stop-splunk]", :immediately
end

service "splunk" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_splunkd" do
    command "/usr/lib/nagios/plugins/check_pidfile /opt/splunk/var/run/splunk/splunkd.pid splunkd"
  end

  nagios_service "SPLUNKD" do
    check_command "check_nrpe!check_splunkd"
  end
end
