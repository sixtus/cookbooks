directory "/opt/splunk/etc/apps/Splunk_TA_hadoopops" do
  action :delete
  recursive true
  not_if { File.directory?("/opt/splunk/etc/apps/Splunk_TA_hadoopops/.git") }
end

directory "/opt/splunk/etc/apps/SA-HadoopOps" do
  action :delete
  recursive true
  not_if { File.directory?("/opt/splunk/etc/apps/SA-HadoopOps/.git") }
end

if !node.role?("splunk-search")
  git "/opt/splunk/etc/apps/Splunk_TA_hadoopops" do
    repository "https://github.com/zenops/splunk-HadoopOps-TA"
    reference "master"
    action :sync
  end
end

git "/opt/splunk/etc/apps/SA-HadoopOps" do
  repository "https://github.com/zenops/splunk-HadoopOps-SA"
  reference "master"
  action :sync
end

hadoop_nodes = node.run_state[:nodes].select do |n|
  n[:hadoop] and
  n[:hadoop][:rack_id]
end

template "/opt/splunk/etc/apps/SA-HadoopOps/bin/topology.py" do
  source "apps/SA-HadoopOps/topology.py"
  owner "root"
  group "root"
  mode "0755"
  variables :hadoop_nodes => hadoop_nodes
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
end
