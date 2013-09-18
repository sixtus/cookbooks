tag("hadoop-datanode")

include_recipe "hadoop"

service "hadoop@datanode" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  {
    :datanode => [:DataNode, 85, 95],
  }.each do |name, params|
    name = name.to_s

    nrpe_command "check_hdfs_#{name}" do
      command "/usr/lib/nagios/plugins/check_hdfs -m #{params[0]} -u http://localhost:50075/jmx -w #{params[1]} -c #{params[2]}"
    end

    nagios_service "HDFS-#{name.gsub(/_/, '-').upcase}" do
      check_command "check_nrpe!check_hdfs_#{name}"
      servicegroups "hadoop"
    end
  end
end
