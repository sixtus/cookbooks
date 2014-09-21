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
  nrpe_command "check_kafka_stat" do
    command "/usr/lib/nagios/plugins/check_jstat -j kafka.Kafka"
  end

  nagios_service "KAFKA" do
    check_command "check_nrpe!check_kafka_stat"
    servicegroups "kafka"
  end

  nagios_cluster_service "KAFKA-NODES" do
    check_command "check_aggregate!KAFKA!0.1!0.3!-H #{kafka_brokers.map(&:fqdn).join(',')}"
    servicegroups "kafka"
  end

  nagios_service "KAFKA-UNDERREPLICATED-PARTITIONS" do
    check_command %{check_jmx!17006!"kafka.server":name="UnderReplicatedPartitions",type="ReplicaManager"!Value!-w 1 -c 2}
    servicegroups "kafka"
  end

  nagios_plugin "check_kafka_lag" do
    source "check_kafka_lag.rb"
  end

  nagios_plugin "check_kafka_partitioning" do
    source "check_kafka_partitioning.rb"
  end
end
