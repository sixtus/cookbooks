package "net-misc/rabbitmq-server"

service "rabbitmq" do
  action [:enable, :start]
end
