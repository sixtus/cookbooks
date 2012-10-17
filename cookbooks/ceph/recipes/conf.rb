raise "monitor secret must be set" if node[:ceph][:monitor_secret].nil?
raise "fsid must be set in config" if node[:ceph][:config][:fsid].nil?

mon_nodes = get_mon_nodes
mds_nodes = get_mds_nodes

service "ceph" do
  action [:enable]
end

template "/etc/ceph/ceph.conf" do
  source "ceph.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[ceph]"
  variables :mon_nodes => mon_nodes,
    :mds_nodes => mds_nodes
end

mons = get_mon_nodes.select do |n|
  n[:ceph_client_admin_key]
end

if mons.empty?
  puts "no ceph-mon found"
else
  execute "create-osd-keyring" do
    command %{ceph-authtool /etc/ceph/ceph.client.admin.keyring --create-keyring --name=client.admin --add-key="#{mons[0][:ceph_client_admin_key]}"}
    creates "/etc/ceph/ceph.client.admin.keyring"
  end
end
