package "net-misc/rabbitmq-server"

directory "/var/log/rabbitmq" do
  owner "rabbitmq"
  group "rabbitmq"
  mode "0750"
end

service "epmd" do
  action [:enable, :start]
end

service "rabbitmq" do
  action [:enable, :start]
end
