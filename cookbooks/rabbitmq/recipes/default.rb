include_recipe "erlang"

package "net-misc/rabbitmq-server"

directory "/var/log/rabbitmq" do
  owner "rabbitmq"
  group "rabbitmq"
  mode "0750"
end

systemd_unit "rabbitmq.service"

execute "wait-for-rabbitmq" do
  command "while ! netstat -tulpen | grep -q 5672; do sleep 1; done"
  action :nothing
end

service "rabbitmq" do
  action [:start, :enable]
  notifies :run, "execute[wait-for-rabbitmq]", :immediately
end
