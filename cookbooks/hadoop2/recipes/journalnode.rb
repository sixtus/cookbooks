include_recipe "hadoop2"

service "hdfs@journalnode" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/hadoop2/core-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/hdfs-site.xml]"
end

nrpe_command "check_hdfs_journalnode_stat" do
  command "/usr/lib/nagios/plugins/check_jstat hadoop2 hdfs@journalnode"
end

nagios_service "HDFS-JOURNALNODE" do
  check_command "check_nrpe!check_hdfs_journalnode_stat"
  servicegroups "hdfs,hdfs-journalnode"
end

nagios_cluster_service "HDFS-JOURNALNODES" do
  check_command "check_aggregate!HDFS-JOURNALNODE!0.3!0.5!#{hadoop2_journalnodes.map(&:fqdn).join(',')}"
  servicegroups "hdfs,hdfs-journalnode"
end

nagios_service "HDFS-JOURNALNODE-RPC" do
  check_command "check_tcp!8485!-w 1 -c 1"
  servicegroups "hdfs,hdfs-journalnode"
end
