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
