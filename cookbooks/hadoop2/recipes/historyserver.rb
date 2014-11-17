include_recipe "hadoop2"

service "mapred@historyserver" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/hadoop2/core-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/hdfs-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/yarn-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/mapred-site.xml]"
end

nrpe_command "check_mapred_historyserver_stat" do
  command "/usr/lib/nagios/plugins/check_jstat -j org.apache.hadoop.mapreduce.v2.hs.JobHistoryServer"
end

nagios_service "MAPRED-HISTORYSERVER" do
  check_command "check_nrpe!check_mapred_historyserver_stat"
  servicegroups "mapred,mapred-historyserver"
end

nagios_cluster_service "MAPRED-HISTORYSERVERS" do
  check_command "check_aggregate!MAPRED-HISTORYSERVER!0.1!0.3!#{hadoop2_historyservers.map(&:fqdn).join(',')}"
  servicegroups "mapred,mapred-historyserver"
end

nagios_service "MAPRED-HISTORYSERVER-RPC" do
  check_command "check_tcp!10033!-w 1 -c 1"
  servicegroups "mapred,mapred-historyserver"
end

{
  :latency => [:HistoryServerLatency, 5, 10],
}.each do |name, params|
  name = name.to_s

  nrpe_command "check_mapred_historyserver_#{name}" do
    command "/usr/lib/nagios/plugins/check_mapred -m #{params[0]} -u http://#{node[:ipaddress]}:19888/jmx -w #{params[1]} -c #{params[2]}"
  end

  nagios_service "MAPRED-HISTORYSERVER-#{name.gsub(/_/, '-').upcase}" do
    check_command "check_nrpe!check_mapred_historyserver_#{name}"
    servicegroups "mapred,mapred-historyserver"
  end
end

nagios_service "MAPRED-HISTORYSERVER-WEBUI" do
  check_command "check_http!-p 19888 -u /jobhistory -r 'Application'"
  servicegroups "mapred,mapred-historyserver"
end
