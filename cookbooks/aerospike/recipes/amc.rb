include_recipe "aerospike"

directory "/etc/amc" do
  owner "root"
  group "root"
  mode "0644"
  action :create
end

file "/opt/amc/bin/gunicorn" do
  owner "root"
  group "root"
  mode "0755"
  action :touch
end

template "/opt/amc/config/gunicorn_config.py" do
  source "gunicorn.py"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[amc]"
end

systemd_unit "amc.service" do
  template true
end

service "amc" do
  action [:enable, :start]
end
