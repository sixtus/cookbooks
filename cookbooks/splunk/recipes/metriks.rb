directory "/opt/splunk/etc/apps/ganymed" do
  action :delete
  recursive true
end

remote_directory "/opt/splunk/etc/apps/metriks" do
  source "apps/metriks"
  files_owner "root"
  files_group "root"
  files_mode "0644"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[splunk]"
end
