raise "monitor secret must be set" if node[:ceph][:monitor_secret].nil?
raise "fsid must be set in config" if node[:ceph][:config][:fsid].nil?
raise "mon_initial_members must be set in config" if node[:ceph][:config][:mon_initial_members].nil?

monitor_nodes = get_mon_nodes()

template "/etc/ceph/ceph.conf" do
  source "ceph.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[ceph]"
  variables :monitor_nodes => monitor_nodes
end
