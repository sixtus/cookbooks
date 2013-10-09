git "/opt/splunk/etc/apps/metriks" do
  repository "https://github.com/zenops/splunk-metriks"
  reference "master"
  action :sync
end
