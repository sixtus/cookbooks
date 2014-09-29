include_recipe "kafka"

node[:kafka][:mirror][:sources].each do |source|
  template "/var/app/kafka/current/config/mirror-consumer-#{source}.properties" do
    variables cluster: source
    source "consumer.properties"
    owner "root"
    group "kafka"
    mode "0640"
    notifies :restart, "service[kafka-mirror]"
  end
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
end

service "kafka-mirror" do
  action [:enable, :start]
end
