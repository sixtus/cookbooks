include_recipe "ceph::default"
include_recipe "ceph::conf"

mons = get_mon_nodes("ceph_bootstrap_osd_key:*")

if mons.empty? then
  puts "No ceph-mon found."
else
  directory "/var/lib/ceph/bootstrap-osd" do
    owner "root"
    group "root"
    mode "0755"
  end

  execute "create-osd-keyring" do
    command %{ceph-authtool '/var/lib/ceph/bootstrap-osd/ceph.keyring' --create-keyring --name=client.bootstrap-osd --add-key="#{mons[0][:ceph_bootstrap_osd_key]}"}
    creates "/var/lib/ceph/bootstrap-osd/ceph.keyring"
  end
end
