# cleanup old cruft
directory "/opt/splunk/etc/apps/Splunk_TA_hadoopops" do
  action :delete
  recursive true
  not_if { File.directory?("/opt/splunk/etc/apps/Splunk_TA_hadoopops/.git") }
end

directory "/opt/splunk/etc/apps/SA-HadoopOps" do
  action :delete
  recursive true
  not_if { File.directory?("/opt/splunk/etc/apps/SA-HadoopOps/.git") }
end

directory "/opt/splunk/etc/apps/splunk_for_hadoopops" do
  action :delete
  recursive true
  not_if { File.directory?("/opt/splunk/etc/apps/splunk_for_hadoopops/.git") }
end

if splunk_forwarder?
  git "/opt/splunk/etc/apps/Splunk_TA_hadoopops" do
    repository "https://github.com/zenops/splunk-HadoopOps-TA"
    reference "master"
    action :sync
  end

  directory "/opt/splunk/etc/apps/Splunk_TA_hadoopops/local" do
    owner "root"
    group "root"
    mode "0755"
  end

  template "/opt/splunk/etc/apps/Splunk_TA_hadoopops/local/inputs.conf" do
    source "apps/TA-HadoopOps/inputs.conf"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[splunk]"
  end
else
  git "/opt/splunk/etc/apps/SA-HadoopOps" do
    repository "https://github.com/zenops/splunk-HadoopOps-SA"
    reference "master"
    action :sync
  end

  template "/opt/splunk/etc/apps/SA-HadoopOps/bin/topology.py" do
    source "apps/SA-HadoopOps/topology.py"
    owner "root"
    group "root"
    mode "0755"
  end

  git "/opt/splunk/etc/apps/splunk_for_hadoopops" do
    repository "https://github.com/zenops/splunk-HadoopOps"
    reference "master"
    action :sync
  end
end
