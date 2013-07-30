case node[:platform]
when "gentoo"
  template "/etc/env.d/99splunk" do
    source "99splunk"
    owner "root"
    group "root"
    mode "0644"
    notifies :run, 'execute[env-update]'
  end
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

pass4symmkey = get_password("splunk/pass4symmkey")

template "/opt/splunk/etc/system/default/server.conf" do
  source "server.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[splunk]"
  variables({
    pass4symmkey: pass4symmkey,
  })
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

systemd_unit "splunk.service"

service "splunk" do
  action [:enable, :start]
end

include_recipe "splunk::systemd"
