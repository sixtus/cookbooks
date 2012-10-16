tag('ceph-mds')

include_recipe "ceph::default"
include_recipe "ceph::conf"

cluster_node = "#{node[:ceph][:cluster]}-#{node[:hostname]}"
keyring = "/var/lib/ceph/mds/#{cluster_node}/keyring"

directory "/var/lib/ceph/mds/#{cluster_node}" do
  recursive true
  owner "root"
  group "root"
  mode "0755"
end

execute "ceph-mds-key" do
  command "ceph auth get-or-create mds.#{node[:hostname]} mon 'allow rwx' osd 'allow *' mds 'allow *' -o #{keyring}"
  creates keyring
  notifies :restart, "service[ceph]"
end
