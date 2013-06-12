case node[:platform]
when "gentoo"
  package "app-admin/logrotate"

when "debian"
  package "logrotate"
end

directory "/etc/logrotate.d" do
  mode "0755"
end

cookbook_file "/etc/logrotate.conf" do
  source "logrotate.conf"
end

cron_daily "logrotate.cron" do
  command "/usr/sbin/logrotate /etc/logrotate.conf"
end

cookbook_file "/etc/logrotate.d/syslog-ng" do
  owner "root"
  group "root"
  mode "0644"
  source "syslog-ng.logrotate"
end
