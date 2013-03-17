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

if tagged?("nagios-client")
  nrpe_command "check_xinetd" do
    command "/usr/lib/nagios/plugins/check_systemd xinetd.service /run/xinetd.pid /usr/sbin/xinetd"
  end

  nagios_service "XINETD" do
    check_command "check_nrpe!check_xinetd"
  end
end
