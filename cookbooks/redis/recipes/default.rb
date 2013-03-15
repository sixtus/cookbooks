package "dev-db/redis"

template "/etc/redis.conf" do
  source "redis.conf"
  owner "root"
  group "root"
  mode "0644"
end

systemd_unit "redis.service"

service "redis" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_redis" do
    command "/usr/lib/nagios/plugins/check_systemd redis.service /run/redis/redis.pid /usr/sbin/redis-server"
  end

  nagios_service "REDIS" do
    check_command "check_nrpe!check_redis"
  end
end
