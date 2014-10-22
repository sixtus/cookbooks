include_recipe "aerospike"

directory "/var/run/aerospike" do
  owner "root"
  group "root"
  mode "0644"
end

directory "/var/log/aerospike" do
  owner "root"
  group "root"
  mode "0644"
end

systemd_unit "xdr.service" do
  template true
end

service "xdr" do
  action [:enable, :start]
end
