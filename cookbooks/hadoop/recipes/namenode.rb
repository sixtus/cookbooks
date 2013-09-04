tag("hadoop-namenode")

include_recipe "hadoop"

if solo?
  execute "hadoop-namenode-format" do
    command "/opt/hadoop/bin/hadoop namenode -format"
    user "hadoop"
    group "hadoop"
    creates "/var/lib/hadoop/name/image/fsimage"
  end
end

service "hadoop@namenode" do
  action [:enable, :start]
end

## Hadoop Balancer cronjob:
cron "hadoop_balancer" do
  minute "0"
  hour "3"
  day "*"
  command "/opt/hadoop/bin/start-balancer.sh"
  action :create
end

if tagged?("nagios-client")
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
