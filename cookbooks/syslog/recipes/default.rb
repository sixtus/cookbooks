if gentoo?
  package "app-admin/syslog-ng"

elsif debian_based?
  package "rsyslog" do
    action :remove
  end

  package "syslog-ng"
end

directory "/etc/syslog-ng/conf.d" do
  action :delete
  recursive true
end

template "/etc/syslog-ng/syslog-ng.conf" do
  source "syslog-ng.conf"
  owner "root"
  group "root"
  mode "0640"
  notifies :restart, "service[syslog-ng]"
end

systemd_unit "syslog-ng.service"

service "syslog-ng" do
  action [:enable, :start]
end

include_recipe "syslog::logrotate"
