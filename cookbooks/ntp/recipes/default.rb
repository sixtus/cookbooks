case node[:platform]
when "gentoo"
  package "net-misc/ntp" do
    notifies :restart, "service[ntpd]"
  end

when "debian"
  package "ntp"
end

template "/etc/ntp.conf" do
  source "ntp.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[ntpd]"
end

file "/etc/conf.d/ntpd" do
  action :delete
end

systemd_unit "ntpd.service"

service "ntpd" do
  service_name "ntpd"
  service_name "ntp" if node[:platform] == "debian"
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_ntpd" do
    command "/usr/lib/nagios/plugins/check_systemd ntpd.service /run/ntpd.pid"
  end

  nagios_service "NTPD" do
    check_command "check_nrpe!check_ntpd"
    servicegroups "system"
    env [:testing, :development]
  end

  nrpe_command "check_time" do
    command "/usr/lib/nagios/plugins/check_ntp_time -H #{node[:ntp][:server]} -w 5 -c 30"
  end

  nagios_service "TIME" do
    check_command "check_nrpe!check_time"
    servicegroups "system"
    env [:testing, :development]
  end
end
