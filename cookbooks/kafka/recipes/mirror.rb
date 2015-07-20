include_recipe "kafka"

template "/var/app/kafka/current/config/mirror-consumer.properties" do
  source "consumer.properties"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka-mirror]"
end

template "/var/app/kafka/current/config/mirror-producer.properties" do
  source "producer.properties"
  owner "root"
  group "kafka"
  mode "0640"
  notifies :restart, "service[kafka-mirror]"
end

systemd_unit "kafka-mirror.service" do
  template true
  notifies :restart, "service[kafka-mirror]"
end

service "kafka-mirror" do
  action [:enable, :start]
end
