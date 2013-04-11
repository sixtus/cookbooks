tag("zookeeper")

include_recipe "java"

package "sys-cluster/zookeeper"

template "/opt/zookeeper/bin/zkServer.sh" do
  source "zkServer.sh"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[zookeeper]"
end

template "/opt/zookeeper/conf/log4j.properties" do
  source "log4j.properties"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[zookeeper]"
end

nodes = node.run_state[:nodes].select do |n|
  n[:tags] and
  n[:tags].include?("zookeeper") and
  n[:zookeeper] and
  n[:zookeeper][:ensamble] == node[:zookeeper][:ensamble]
end.sort_by do |n|
  n[:fqdn]
end

myid = nodes.index do |n|
  n[:fqdn] == node[:fqdn]
end.to_i + 1

template "/opt/zookeeper/conf/zoo.cfg" do
  source "zoo.cfg"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[zookeeper]"
  variables :nodes => nodes
end

file "/var/lib/zookeeper/myid" do
  content "#{myid}\n"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[zookeeper]"
end

systemd_unit "zookeeper.service"

service "zookeeper" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_zookeeper" do
    command "/usr/lib/nagios/plugins/check_systemd zookeeper.service"
  end

  nagios_service "ZOOKEEPER" do
    check_command "check_nrpe!check_zookeeper"
  end
end
