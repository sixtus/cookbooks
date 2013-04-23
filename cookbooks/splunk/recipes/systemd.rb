directory "/opt/splunk/etc/apps/systemd-journal" do
  action :delete
  recursive true
  notifies :restart, "service[splunk]"
end
