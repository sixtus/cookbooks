include_recipe "erlang"

package "net-misc/rabbitmq-server"

directory "/var/log/rabbitmq" do
  owner "rabbitmq"
  group "rabbitmq"
  mode "0750"
end

service "rabbitmq" do
  action [:enable, :start]
end
