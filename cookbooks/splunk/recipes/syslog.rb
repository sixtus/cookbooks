include_recipe "syslog::server"

syslog_config "90-splunk" do
  template "syslog.conf"
end

remote_directory "/opt/splunk/etc/apps/syslog_priority_lookup" do
  source "apps/syslog_priority_lookup"
  files_owner "root"
  files_group "root"
  files_mode "0644"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[splunk]"
end
