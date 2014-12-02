# cleanup cruft from SysV init & friends
%w(
  dcron
  syslog-ng
).each do |s|
  service s do
    action [:disable, :stop]
  end
end

service "network.service" do
  action :disable
  provider Chef::Provider::Service::Systemd
end

%w(
  dcron
  network
  syslog-ng
).each do |u|
  systemd_unit u do
    action :delete
  end
end

%w(
  /etc/crontab
  /etc/ifdown
  /etc/ifup
  /etc/inittab
  /etc/systemd/system/multi-user.target.wants/dcron.service
  /etc/systemd/system/multi-user.target.wants/syslog-ng.service
  /etc/systemd/system/syslog.service
).each do |f|
  file f do
    action :delete
  end
end

%w(
  /etc/conf.d
  /etc/cron.d
  /etc/cron.daily
  /etc/cron.hourly
  /etc/cron.monthly
  /etc/cron.weekly
  /etc/init.d
  /etc/local.d
  /etc/syslog-ng
  /etc/xinetd.d
  /var/spool/cron
).each do |d|
  directory d do
    action :delete
    recursive true
  end
end

