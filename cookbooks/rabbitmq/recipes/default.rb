package "net-misc/rabbitmq-server"

directory "/var/log/rabbitmq" do
  owner "rabbitmq"
  group "rabbitmq"
  mode "0770"
end

service "rabbitmq" do
  action [:enable, :start]
end
