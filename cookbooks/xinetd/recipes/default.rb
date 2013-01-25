package "sys-apps/xinetd"

template "/etc/xinetd.conf" do
  source "xinetd.conf"
  owner "root"
  group "root"
  notifies :restart, 'service[xinetd]'
end

service "xinetd" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_xinetd" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/xinetd.pid /var/run/xinetd.pid"
  end

  nagios_service "XINETD" do
    check_command "check_nrpe!check_xinetd"
  end
end
