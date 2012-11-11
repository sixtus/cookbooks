portage_package_use "sys-cluster/hadoop" do
  use %w(ceph)
end

package "sys-cluster/hadoop"

%w(
  /var/log/hadoop
  /var/run/hadoop
  /var/tmp/hadoop
).each do |dir|
  directory dir do
    owner "hadoop"
    group "hadoop"
    mode "0755"
  end
end

%w(
  jobtracker
  tasktracker
).each do |svc|
  cookbook_file "/etc/init.d/hadoop-#{svc}" do
    source "#{svc}.initd"
    owner "root"
    group "root"
    mode "0755"
  end
end

## ceph integration
ceph_mon = get_mon_nodes.select do |n|
  n[:ceph_client_admin_key]
end.first

execute "create-hadoop-ceph-keyring" do
  command %{ceph-authtool /opt/hadoop/conf/ceph.keyring --create-keyring --name=client.admin --add-key="#{ceph_mon[:ceph_client_admin_key]}"}
  creates "/opt/hadoop/conf/ceph.keyring"
end

file "/opt/hadoop/conf/ceph.keyring" do
  owner "hadoop"
  group "hadoop"
  mode "0400"
end

job_tracker = node.run_state[:nodes].select do |n|
  n[:tags] && n[:tags].include?("hadoop-jobtracker")
end.first

%w(
  core-site.xml
  hadoop-env.sh
  log4j.properties
  mapred-site.xml
).each do |f|
  template "/opt/hadoop/conf/#{f}" do
    source f
    owner "root"
    group "root"
    mode "0644"
    variables :ceph_mon => ceph_mon,
              :job_tracker => job_tracker
  end
end
