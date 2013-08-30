include_recipe "java"

package "sys-cluster/hadoop"
package "dev-lang/apache-pig-bin"

%w(
  /var/lib/hadoop
  /var/log/hadoop
  /var/run/hadoop
).each do |dir|
  directory dir do
    owner "hadoop"
    group "hadoop"
    mode "0775"
  end
end

directory "/opt/hadoop/logs" do
  action :delete
  recursive true
  only_if { File.directory?("/opt/hadoop/logs") }
end

link "/opt/hadoop/logs" do
  to "/var/log/hadoop"
end

systemd_unit "hadoop@.service"

name_node = node.run_state[:nodes].select do |n|
  n[:tags] && n[:tags].include?("hadoop-namenode")
end.first

job_tracker = node.run_state[:nodes].select do |n|
  n[:tags] && n[:tags].include?("hadoop-jobtracker")
end.first

%w(
  core-site.xml
  hadoop-env.sh
  hadoop-metrics2.properties
  hdfs-site.xml
  log4j.properties
  mapred-site.xml
  fair-scheduler.xml
).each do |f|
  template "/opt/hadoop/conf/#{f}" do
    source f
    owner "root"
    group "root"
    mode "0644"
    variables :job_tracker => job_tracker,
              :name_node => name_node
  end
end

template "/opt/hadoop/conf/topology.sh" do
  source "topology.sh"
  owner "root"
  group "hadoop"
  mode "0554"
end

datanodes = node.run_state[:nodes].select do |n|
  n[:tags] and n[:tags].include?("hadoop-datanode")
end

topology = datanodes.map do |n|
  "#{node[:ipaddress]} #{node[:hadoop][:rack_id] || '/default/rack'}"
end.join("\n") + "\n"

file "/opt/hadoop/conf/topology.data" do
  action :create
  owner "root"
  group "hadoop"
  mode "0644"
  content topology
end

directory node[:hadoop][:tmp_dir] do
  owner "hadoop"
  group "hadoop"
  mode "0777"
  recursive true
end

directory node[:hadoop][:java_tmp] do
  owner "hadoop"
  group "hadoop"
  mode "0777"
  recursive true
end

nagios_plugin "check_hdfs" do
  source "check_hdfs.rb"
end

if tagged?("splunk-forwarder")
  include_recipe "splunk::hadoop-ops"

  directory "/opt/splunk/etc/apps/Splunk_TA_hadoopops/local" do
    owner "root"
    group "root"
    mode "0755"
  end

  template "/opt/splunk/etc/apps/Splunk_TA_hadoopops/local/inputs.conf" do
    source "splunk/inputs.conf"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[splunk]"
  end
end
