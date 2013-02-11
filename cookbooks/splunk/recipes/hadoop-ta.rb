%w(
  Splunk_TA_hadoopops
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

%w(
  common.sh
  hadoop.introspect.sh
  hadoopmon_common.sh
  hadoopmon_cpu.sh
  hadoopmon_df.sh
  hadoopmon_dfsreport.sh
  hadoopmon_fsckreport.sh
  hadoopmon_iostat.sh
  hadoopmon_jobclient.sh
  hadoopmon_ps.sh
  hadoopmon_top.sh
  hadoopmon_vmstat.sh
  hopsconfig.sh
  introspect.jt.inputs
  introspect.sh
  introspect.tt.inputs
  jmxclient.sh
).each do |f|
  file "/opt/splunk/etc/apps/Splunk_TA_hadoopops/bin/#{f}" do
    owner "root"
    group "root"
    mode "0755"
  end
end
