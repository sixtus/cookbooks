package "dev-db/redis"

service "redis" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_redis" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/redis/redis.pid /usr/sbin/redis-server"
  end

  nagios_service "REDIS" do
    check_command "check_nrpe!check_redis"
  end
end
