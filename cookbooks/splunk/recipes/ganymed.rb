remote_directory "/opt/splunk/etc/apps/ganymed" do
  source "apps/ganymed"
  files_owner "root"
  files_group "root"
  files_mode "0644"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[splunk]"
end
