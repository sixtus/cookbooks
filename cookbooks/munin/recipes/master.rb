tag("munin-master")

include_recipe "munin"

package "media-fonts/dejavu"

directory "/etc/ssl/munin" do
  owner "root"
  group "root"
  mode "0755"
end

ssl_ca "/etc/ssl/munin/ca" do
  owner "munin"
  group "munin"
end

ssl_certificate "/etc/ssl/munin/master" do
  cn node[:fqdn]
  owner "munin"
  group "munin"
end

nodes = node.run_state[:nodes].select do |n|
  n[:tags].include?("munin-node")
end

template "/etc/munin/munin.conf" do
  source "munin.conf"
  owner "root"
  group "root"
  mode "0644"
  variables :nodes => nodes
end

cron "munin-cron" do
  action :delete
  user "munin"
end

cron "munin-update" do
  command "/usr/libexec/munin/munin-update"
  minute "*/1"
  user "munin"
end

cron "munin-limits" do
  command "/usr/libexec/munin/munin-limits"
  minute "*/2"
  user "munin"
end

cron "munin-graph" do
  command "/usr/bin/nice /usr/libexec/munin/munin-graph --cron"
  minute "*/5"
  user "munin"
end

cron "munin-html" do
  command "/usr/bin/nice /usr/libexec/munin/munin-html"
  minute "*/15"
  user "munin"
end

munin_plugin "munin_update"
munin_plugin "munin_stats"

nagios_plugin "munin" do
  source "check_munin"
end
