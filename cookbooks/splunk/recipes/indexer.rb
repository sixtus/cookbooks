tag("splunk-indexer")

node.set[:syslog][:archivedir] = false

package "net-analyzer/splunk"

include_recipe "splunk"

## users
splunk_users = Proc.new do |u|
  (u[:tags]) and
  (u[:tags].include?("hostmaster") or u[:tags].include?("splunk")) and
  (u[:password1] and u[:password1] != '!')
end

template "/opt/splunk/etc/passwd" do
  source "passwd"
  owner "root"
  group "root"
  mode "0644"
  variables :splunk_users => node.run_state[:users].select(&splunk_users)
end

## global configuration
%w(
  alert_actions
  eventtypes
  indexes
  props
  tags
  times
  transforms
).each do |c|
  template "/opt/splunk/etc/system/local/#{c}.conf" do
    source "#{c}.conf"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[splunk]"
  end
end

# this is in default rather than local, since splunk seems to have some
# problems with overriding the saved searches in local files
template "/opt/splunk/etc/apps/search/default/savedsearches.conf" do
  source "savedsearches.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[splunk]"
end

## splunk apps
include_recipe "splunk::syslog"
include_recipe "splunk::nagios"
include_recipe "splunk::metriks"
include_recipe "splunk::hadoop-connect"
include_recipe "splunk::hadoop-ops"

## nginx ssl proxy
include_recipe "nginx"

htpasswd_from_users "/etc/nginx/servers/splunk.passwd" do
  query splunk_users
  group "nginx"
  password_field :password1
end

nginx_server "splunk" do
  template "nginx.conf"
end
