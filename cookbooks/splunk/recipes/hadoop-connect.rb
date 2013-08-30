directory "/opt/splunk/etc/apps/HadoopConnect" do
  action :delete
  recursive true
  not_if { File.directory?("/opt/splunk/etc/apps/HadoopConnect/.git") }
end

git "/opt/splunk/etc/apps/HadoopConnect" do
  repository "https://github.com/zenops/splunk-HadoopConnect"
  reference "master"
  action :sync
end
