directory "/opt/splunk/etc/apps/Splunk_TA_hadoopops" do
  action :delete
  recursive true
  not_if { File.directory?("/opt/splunk/etc/apps/Splunk_TA_hadoopops/.git") }
end

git "/opt/splunk/etc/apps/Splunk_TA_hadoopops" do
  repository "https://github.com/zenops/splunk-HadoopOps-TA"
  reference "master"
  action :sync
  notifies :restart, "service[splunk]"
end

if tagged?("splunk-indexer")
  directory "/opt/splunk/etc/apps/SA-HadoopOps" do
    action :delete
    recursive true
    not_if { File.directory?("/opt/splunk/etc/apps/SA-HadoopOps/.git") }
  end

  git "/opt/splunk/etc/apps/SA-HadoopOps" do
    repository "https://github.com/zenops/splunk-HadoopOps-SA"
    reference "master"
    action :sync
    notifies :restart, "service[splunk]"
  end

  directory "/opt/splunk/etc/apps/splunk_for_hadoopops" do
    action :delete
    recursive true
    not_if { File.directory?("/opt/splunk/etc/apps/splunk_for_hadoopops/.git") }
  end

  git "/opt/splunk/etc/apps/splunk_for_hadoopops" do
    repository "https://github.com/zenops/splunk-HadoopOps"
    reference "master"
    action :sync
    notifies :restart, "service[splunk]"
  end
end
