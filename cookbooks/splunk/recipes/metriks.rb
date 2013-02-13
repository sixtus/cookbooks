directory "/opt/splunk/etc/apps/metriks" do
  action :delete
  recursive true
  not_if { File.directory?("/opt/splunk/etc/apps/metriks/.git") }
end

git "/opt/splunk/etc/apps/metriks" do
  repository "https://github.com/zenops/splunk-metriks"
  reference "master"
  action :sync
  notifies :restart, "service[splunk]"
end
