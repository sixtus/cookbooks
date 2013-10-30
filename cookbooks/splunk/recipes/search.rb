include_recipe "splunk"

## global configuration
%w(
  alert_actions
  eventtypes
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
  end
end

# this is in default rather than local, since splunk seems to have some
# problems with overriding the saved searches in local files
template "/opt/splunk/etc/apps/search/default/savedsearches.conf" do
  source "savedsearches.conf"
  owner "root"
  group "root"
  mode "0644"
end

## splunk apps
include_recipe "splunk::syslog"
include_recipe "splunk::nagios"
include_recipe "splunk::unix"
include_recipe "splunk::dbconnect"
include_recipe "splunk::hadoop-ops"
include_recipe "splunk::hadoop-connect"
