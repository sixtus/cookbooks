tag("hadoop-datanode")

include_recipe "hadoop::default"

service "hadoop-datanode" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_hadoop_datanode" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/hadoop/datanode.pid"
  end

  nagios_service "HADOOP-DATANODE" do
    check_command "check_nrpe!check_hadoop_datanode"
  end
end
