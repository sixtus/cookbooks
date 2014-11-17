include_recipe "hadoop2"

service "hdfs@datanode" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/hadoop2/core-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/hdfs-site.xml]"
end

nrpe_command "check_hdfs_datanode_stat" do
  command "/usr/lib/nagios/plugins/check_jstat -j org.apache.hadoop.hdfs.server.datanode.DataNode"
end

nagios_service "HDFS-DATANODE" do
  check_command "check_nrpe!check_hdfs_datanode_stat"
  servicegroups "hdfs,hdfs-datanode"
end

nagios_cluster_service "HDFS-DATANODES" do
  check_command "check_aggregate!HDFS-DATANODE!0.1!0.3!#{hadoop2_datanodes.map(&:fqdn).join(',')}"
  servicegroups "hdfs,hdfs-datanode"
end

nagios_service "HDFS-DATANODE-RPC" do
  check_command "check_tcp!50020!-w 1 -c 1"
  servicegroups "hdfs,hdfs-datanode"
end

nrpe_command "check_hdfs_datanode_used" do
  command "/usr/lib/nagios/plugins/check_hdfs -m DataNodeUsed -u http://localhost:50075/jmx -w 75 -c 90"
end

nagios_service "HDFS-DATANODE-USED" do
  check_command "check_nrpe!check_hdfs_datanode_used"
  servicegroups "hdfs,hdfs-datanode"
end

nagios_cluster_service "HDFS-DATANODES-USED" do
  check_command "check_aggregate!HDFS-DATANODE-USED!0.1!0.3!#{hadoop2_datanodes.map(&:fqdn).join(',')}"
  servicegroups "hdfs,hdfs-datanode"
end
