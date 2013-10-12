if gentoo?
  %w(sys-process/dcron dev-util/lockrun).each do |p|
    package p
  end
elsif debian?
  apt_repository "balocco" do
    uri "http://apt.balocco.name"
    distribution node[:lsb][:codename]
    components %w(main)
    keyserver "keyserver.ubuntu.com"
    key "92B84A1E"
  end

  package "cron" do
    action :remove
  end

  package "dcron"
end

%w(d hourly daily weekly monthly).each do |dir|
  directory "/etc/cron.#{dir}" do
    mode "0750"
  end
end

cookbook_file "/usr/bin/crond-journal" do
  source "crond-journal.sh"
  owner "root"
  group "root"
  mode "0755"
end

systemd_tmpfiles "dcron"
systemd_unit "dcron.service"

service "dcron" do
  service_name "cron" if ubuntu?
  action [:enable, :start]
end

file "/etc/crontab" do
  action :delete
  backup 0
end

cron "lastrun-hourly" do
  minute node[:cron][:hourly][:minute]
  command "rm -f /var/spool/cron/lastrun/cron.hourly"
end

cron "lastrun-daily" do
  minute node[:cron][:daily][:minute]
  hour node[:cron][:daily][:hour]
  command "rm -f /var/spool/cron/lastrun/cron.daily"
end

cron "lastrun-weekly" do
  minute node[:cron][:weekly][:minute]
  hour node[:cron][:weekly][:hour]
  weekday node[:cron][:weekly][:wday]
  command "rm -f /var/spool/cron/lastrun/cron.weekly"
end

cron "lastrun-monthly" do
  minute node[:cron][:monthly][:minute]
  hour node[:cron][:monthly][:hour]
  day node[:cron][:monthly][:wday]
  command "rm -f /var/spool/cron/lastrun/cron.monthly"
end

cron "run-crons" do
  minute "*/10"
  command "/usr/bin/test -x /usr/sbin/run-crons && /usr/sbin/run-crons"
end

if tagged?("nagios-client")
  cron "heartbeat" do
    command "/usr/bin/touch /tmp/.check_cron"
    minute "0"
  end

  nagios_plugin "check_cron"

  nrpe_command "check_cron" do
    command "/usr/lib/nagios/plugins/check_cron"
  end

  nagios_service "CRON" do
    check_command "check_nrpe!check_cron"
    servicegroups "system"
    env [:testing, :development]
  end

  nagios_plugin "check_long_running_cronjobs"

  nrpe_command "check_long_running_cronjobs" do
    command "/usr/lib/nagios/plugins/check_long_running_cronjobs"
  end

  nagios_service "CRONJOBS" do
    check_command "check_nrpe!check_long_running_cronjobs"
    check_interval 60
    env [:testing, :development]
  end
end
