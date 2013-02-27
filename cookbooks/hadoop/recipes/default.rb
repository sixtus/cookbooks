include_recipe "java"

package "sys-cluster/hadoop"

%w(
  /var/lib/hadoop
  /var/log/hadoop
  /var/run/hadoop
  /var/tmp/hadoop
).each do |dir|
  directory dir do
    owner "hadoop"
    group "hadoop"
    mode "0775"
  end
end

%w(
  namenode
  datanode
  jobtracker
  tasktracker
).each do |svc|
  cookbook_file "/etc/init.d/hadoop-#{svc}" do
    source "#{svc}.initd"
    owner "root"
    group "root"
    mode "0755"
  end
end

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

node[:hadoop][:tmp_dir].each do |dir|
  directory dir do
    owner "hadoop"
    group "hadoop"
    mode "0777"
    recursive true
  end
end

if tagged?("splunk-forwarder")
  include_recipe "splunk::hadoop-ops"
end
