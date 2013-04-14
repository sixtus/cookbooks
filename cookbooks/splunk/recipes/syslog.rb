git "/opt/splunk/etc/apps/syslog_priority_lookup" do
  repository "https://github.com/zenops/splunk-syslog_priority_lookup"
  reference "master"
  action :sync
  notifies :restart, "service[splunk]"
end

template "/opt/splunk/etc/apps/syslog_priority_lookup/local/props.conf" do
  source "apps/syslog_priority_lookup/props.conf"
  owner "root"
  group "root"
  mode "0644"
end
