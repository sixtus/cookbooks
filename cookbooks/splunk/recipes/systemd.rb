git "/opt/splunk/etc/apps/systemd-journal" do
  repository "https://github.com/zenops/splunk-systemd-journal"
  reference "master"
  action :sync
  notifies :restart, "service[splunk]"
end
