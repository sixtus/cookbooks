tag("hadoop-namenode")

include_recipe "hadoop"

service "hadoop@namenode" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_hadoop_namenode" do
    command "/usr/lib/nagios/plugins/check_systemd hadoop@namenode /run/hadoop/namenode.pid"
  end

  nagios_service "HADOOP-NAMENODE" do
    check_command "check_nrpe!check_hadoop_namenode"
  end

  {
    :nodes => [:NameNode, nil, nil],
    :state => [:Dfs, nil, nil],
    :capacity => [:DfsCapacity, 75, 90],
    :blocks => [:DfsBlocks, 50, 100],
    :queue => [:RpcQueue, 0.25, 0.5],
  }.each do |name, params|
    name = name.to_s

    nrpe_command "check_hdfs_#{name}" do
      command "/usr/lib/nagios/plugins/check_hdfs -m #{params[0]} -u http://localhost:50070/jmx -w #{params[1]} -c #{params[2]}"
    end

    nagios_service "HDFS-#{name.gsub(/_/, '-').upcase}" do
      check_command "check_nrpe!check_hdfs_#{name}"
      servicegroups "hadoop"
    end
  end
end
