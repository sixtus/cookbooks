tag("hadoop-namenode")

include_recipe "hadoop"

service "hadoop-namenode" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_hadoop_namenode" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/hadoop/namenode.pid"
  end

  nagios_service "HADOOP-NAMENODE" do
    check_command "check_nrpe!check_hadoop_namenode"
  end
end
