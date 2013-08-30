git "/opt/splunk/etc/apps/syslog_priority_lookup" do
  repository "https://github.com/zenops/splunk-syslog_priority_lookup"
  reference "master"
  action :sync
end
