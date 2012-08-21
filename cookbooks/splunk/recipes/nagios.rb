remote_directory "/opt/splunk/etc/apps/SplunkForNagios" do
  source "apps/SplunkForNagios"
  files_owner "root"
  files_group "root"
  files_mode "0644"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[splunk]"
end

master = node.run_state[:nodes].select do |n|
  n[:tags].include?("nagios-master")
end.first

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
    variables :master => master
  end
end
