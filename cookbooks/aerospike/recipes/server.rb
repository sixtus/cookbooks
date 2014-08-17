package "dev-db/aerospike"

template "/etc/aerospike/aerospike.conf" do
  source "aerospike.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[aerospike]"
end

systemd_unit "aerospike.service" do
  template true
end

service "aerospike" do
  action [:enable, :start]
end

template "/opt/amc/config/gunicorn_config.py" do
  source "gunicorn.py"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[amc]"
end

service "amc" do
  action [:enable, :start]
end
