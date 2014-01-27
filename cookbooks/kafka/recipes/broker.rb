include_recipe "kafka"

folders = ['/var/log/kafka'] + node[:kafka][:storage].split(',')

folders.each do |dir|
  directory dir do
    owner "kafka"
    group "kafka"
    mode "0755"
  end
end

template "/etc/kafka/server.config" do
  source "server.config"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka]"
end

systemd_unit "kafka.service"

service "kafka" do
  action [:enable, :start]
end

if nagios_client?
  # TODO: rethinking
  
  # if gentoo?
  #   package "sys-cluster/zookeeper"
  # elsif mac_os_x?
  #   package "zookeeper"
  # end

  # nrpe_command "check_kafka_lagging" do
  #   command "/usr/lib/nagios/plugins/check_kafka_lag -Z #{ zookeeper_connect(node[:kafka][:zookeeper][:root]) }"
  # end

  # nagios_service "KAFKA08-LAG" do
  #   check_command "check_nrpe!check_kafka_lagging"
  # end
end
