package "net-misc/memcached"

systemd_unit "memcached.service" do
  template true
  notifies :restart, "service[memcached]"
end

service "memcached" do
  action [:enable, :start]
end
