package "sys-apps/xinetd"

template "/etc/xinetd.conf" do
  source "xinetd.conf"
  owner "root"
  group "root"
  notifies :restart, 'service[xinetd]'
end

systemd_unit "xinetd.service"

service "xinetd" do
  action [:enable, :start]
end
