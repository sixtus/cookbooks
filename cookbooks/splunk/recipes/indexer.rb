tag("splunk-indexer")

package "net-analyzer/splunk"

include_recipe "splunk::default"

remote_directory "/opt/splunk/etc/apps/syslog_priority_lookup" do
  source "apps/syslog_priority_lookup"
  files_owner "root"
  files_group "root"
  files_mode "0644"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[splunk]"
end

template "/opt/splunk/etc/apps/search/default/savedsearches.conf" do
  source "savedsearches.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[splunk]"
end

include_recipe "syslog::server"

syslog_config "90-splunk" do
  template "syslog.conf"
end

include_recipe "nginx"

query = Proc.new do |u|
  u[:tags] and
  (u[:tags].include?("hostmaster") or u[:tags].include?("splunk"))
end

htpasswd_from_databag "/etc/nginx/servers/splunk.passwd" do
  query query
  group "nginx"
end

nginx_server "splunk" do
  template "nginx.conf"
end
