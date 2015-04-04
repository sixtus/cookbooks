include_recipe "hadoop2"

service "yarn@nodemanager" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/hadoop2/core-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/hdfs-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/yarn-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/mapred-site.xml]"
end

nrpe_command "check_yarn_nodemanager_stat" do
  command "/usr/lib/nagios/plugins/check_jstat hadoop2 yarn@nodemanager"
end

nagios_service "YARN-NODEMANAGER" do
  check_command "check_nrpe!check_yarn_nodemanager_stat"
  servicegroups "yarn,yarn-nodemanager"
end

nagios_cluster_service "YARN-NODEMANAGERS" do
  check_command "check_aggregate!YARN-NODEMANAGER!0.1!0.3!#{hadoop2_nodemanagers.map(&:fqdn).join(',')}"
  servicegroups "yarn,yarn-nodemanager"
end

nagios_service "YARN-NODEMANAGER-RPC" do
  check_command "check_tcp!8040!-w 1 -c 1"
  servicegroups "yarn,yarn-nodemanager"
end

{
  :latency => [:NodeManagerLatency, 5, 10],
}.each do |name, params|
  name = name.to_s

  nrpe_command "check_yarn_nodemanager_#{name}" do
    command "/usr/lib/nagios/plugins/check_yarn -m #{params[0]} -u http://#{node[:ipaddress]}:8042/jmx -w #{params[1]} -c #{params[2]}"
  end

  nagios_service "YARN-NODEMANAGER-#{name.gsub(/_/, '-').upcase}" do
    check_command "check_nrpe!check_yarn_nodemanager_#{name}"
    servicegroups "yarn,yarn-nodemanager"
  end
end

nagios_service "YARN-NODEMANAGER-HEALTHY" do
  check_command "check_http!-p 8042 -u /ws/v1/node/info -s '\"nodeHealthy\":true'"
  servicegroups "yarn,yarn-nodemanager"
end
