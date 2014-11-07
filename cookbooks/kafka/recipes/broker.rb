include_recipe "kafka"

node[:kafka][:storage].split(',').each do |dir|
  directory dir do
    owner "kafka"
    group "kafka"
    mode "0755"
  end
end

cookbook_file "/var/app/kafka/current/libs/metrics-kafka.jar" do
  source "metrics-kafka.jar"
  owner "root"
  group "kafka"
  mode "0644"
end

template "/var/app/kafka/current/config/server.properties" do
  source "server.properties"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka]"
end

include_recipe "zookeeper::ruby"

ruby_block "kafka-zk-chroot" do
  block do
    Gem.clear_paths
    require 'zk'
    ZK.new(zookeeper_connect(node[:kafka][:zookeeper][:root], node[:kafka][:zookeeper][:cluster]))
  end
end

systemd_unit "kafka.service"

service "kafka" do
  action [:enable, :start]
end

if nagios_client?
  nagios_plugin "check_kafka"

  nrpe_command "check_kafka_jvm_memory" do
    command "/usr/lib/nagios/plugins/check_jvm -u http://localhost:29092/jolokia -m MemoryPool -w 75 -c 90"
  end

  nagios_service "KAFKA-JVM-MEMORY" do
    check_command "check_nrpe!check_kafka_jvm_memory"
    servicegroups "kafka"
  end

  nagios_cluster_service "KAFKA-NODES" do
    check_command "check_aggregate!KAFKA-JVM-MEMORY!0.1!0.3!-H #{kafka_brokers.map(&:fqdn).join(',')}"
    servicegroups "kafka"
  end

  nrpe_command "check_kafka_under_replicated_partitions" do
    command "/usr/lib/nagios/plugins/check_kafka -u http://localhost:29092/jolokia -m UnderReplicatedPartitions"
  end

  nagios_service "KAFKA-UNDERREPLICATED-PARTITIONS" do
    check_command "check_nrpe!check_kafka_under_replicated_partitions"
    servicegroups "kafka"
  end

  nagios_plugin "check_kafka_topics" do
    source "check_kafka_topics"
  end

  nrpe_command "check_kafka_topics" do
    command "/usr/lib/nagios/plugins/check_kafka_topics -Z #{zookeeper_connect(node[:kafka][:zookeeper][:root], node[:kafka][:zookeeper][:cluster])} -b #{node[:cluster][:host][:id]}"
  end

  nagios_service "KAFKA-TOPICS" do
    check_command "check_nrpe!check_kafka_topics"
    servicegroups "kafka"
  end

  nagios_plugin "check_kafka_lag" do
    source "check_kafka_lag.rb"
  end

end
