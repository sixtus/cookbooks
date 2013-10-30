include_recipe "splunk"

%w(
  indexes
  props
  transforms
).each do |c|
  template "/opt/splunk/etc/system/local/#{c}.conf" do
    source "#{c}.conf"
    owner "root"
    group "root"
    mode "0644"
  end
end

include_recipe "splunk::syslog"
include_recipe "splunk::nagios"
include_recipe "splunk::unix"
include_recipe "splunk::hadoop-ops"
