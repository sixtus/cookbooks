directory "/opt/splunk/etc/apps/SplunkForNagios" do
  action :delete
  recursive true
  not_if { File.directory?("/opt/splunk/etc/apps/SplunkForNagios/.git") }
end

git "/opt/splunk/etc/apps/SplunkForNagios" do
  repository "https://github.com/zenops/splunk-for-nagios"
  reference "master"
  action :sync
end

%w(
  livehostsupstatus.py
  livehostsdownstatus.py
  livehostsunreachablestatus.py
  liveserviceokstatus.py
  liveservicewarningstatus.py
  liveservicecriticalstatus.py
  liveserviceunknownstatus.py
  liveservicestate.py
  splunk-nagios-hosts.py
  splunk-nagios-servicegroupmembers.py
  splunk-nagios-servicegroupmembers.sh
).each do |f|
  template "/opt/splunk/etc/apps/SplunkForNagios/bin/#{f}" do
    source "apps/SplunkForNagios/bin/#{f}"
    owner "root"
    group "root"
    mode "0755"
    variables :master => nagios_node
  end
end
