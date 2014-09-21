include_recipe "hadoop2"

service "yarn@resourcemanager" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/hadoop2/core-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/hdfs-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/yarn-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/mapred-site.xml]"
end

nrpe_command "check_yarn_resourcemanager_stat" do
  command "/usr/lib/nagios/plugins/check_jstat -j org.apache.hadoop.yarn.server.resourcemanager.ResourceManager"
end

nagios_service "YARN-RESOURCEMANAGER" do
  check_command "check_nrpe!check_yarn_resourcemanager_stat"
  servicegroups "yarn,yarn-resourcemanager"
end

nagios_cluster_service "YARN-RESOURCEMANAGERS" do
  check_command "check_aggregate!YARN-RESOURCEMANAGER!0.1!0.3"
  servicegroups "yarn,yarn-resourcemanager"
end

nagios_service "YARN-RESOURCEMANAGER-RPC" do
  check_command "check_tcp!23141!-w 1 -c 1"
  servicegroups "yarn,yarn-resourcemanager"
end

{
  :latency => [:ResourceManagerLatency, 5, 10],
}.each do |name, params|
  name = name.to_s

  nrpe_command "check_yarn_resourcemanager_#{name}" do
    command "/usr/lib/nagios/plugins/check_yarn -m #{params[0]} -u http://#{node[:ipaddress]}:8088/jmx -w #{params[1]} -c #{params[2]}"
  end

  nagios_service "YARN-RESOURCEMANAGER-#{name.gsub(/_/, '-').upcase}" do
    check_command "check_nrpe!check_yarn_resourcemanager_#{name}"
    servicegroups "yarn,yarn-resourcemanager"
  end
end

nagios_service "YARN-RESOURCEMANAGER-WEBUI" do
  check_command "check_http!-p 8088 -u /cluster -r '(standby|Applications)'"
  servicegroups "yarn,yarn-resourcemanager"
end
