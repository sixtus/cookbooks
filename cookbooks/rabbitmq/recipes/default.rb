include_recipe "erlang"

package "net-misc/rabbitmq-server"

directory "/var/log/rabbitmq" do
  owner "rabbitmq"
  group "rabbitmq"
  mode "0750"
end

systemd_unit "rabbitmq.service"

service "rabbitmq" do
  action [:enable, :start]
end
