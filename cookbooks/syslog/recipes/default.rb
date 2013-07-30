case node[:platform]
when "gentoo"
  package "app-admin/syslog-ng"

when "debian"
  package "rsyslog" do
    action :remove
  end

  package "syslog-ng"
end

directory "/etc/syslog-ng/conf.d" do
  action :delete
  recursive true
end

indexer_nodes = node.run_state[:nodes].select do |n|
  n[:tags].include?("splunk-indexer") rescue false
end

template "/etc/syslog-ng/syslog-ng.conf" do
  source "syslog-ng.conf"
  owner "root"
  group "root"
  mode "0640"
  notifies :restart, "service[syslog-ng]"
  variables :indexer_nodes => indexer_nodes
end

systemd_unit "syslog-ng.service"

service "syslog-ng" do
  action [:enable, :start]
end

include_recipe "syslog::logrotate"
