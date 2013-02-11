include_recipe "splunk::hadoop-ta"

%w(
  splunk_for_hadoopops
  SA-HadoopOps
  HadoopConect
).each do |app|
  remote_directory "/opt/splunk/etc/apps/#{app}" do
    source "apps/#{app}"
    files_owner "root"
    files_group "root"
    files_mode "0644"
    owner "root"
    group "root"
    mode "0755"
    notifies :restart, "service[splunk]"
  end
end
