package "net-misc/rsync"

template "/etc/rsyncd.conf" do
  source "rsyncd.conf"
  owner "root"
  group "root"
  mode "0640"
  notifies :restart, "service[rsyncd]"
end

service "rsyncd" do
  action [:enable, :start]
end
