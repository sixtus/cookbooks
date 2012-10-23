tag('ceph-mon')

include_recipe "ceph::default"
include_recipe "ceph::conf"

cluster_node = "#{node[:ceph][:cluster]}-#{node[:hostname]}"
keyring = "/var/lib/ceph/tmp/#{cluster_node}.mon.keyring"

execute "create-ceph-keyring" do
  command %{ceph-authtool "#{keyring}" --create-keyring --name=mon. --add-key='#{node[:ceph][:monitor_secret]}' --cap mon 'allow *'}
  not_if { File.exist?("/var/lib/ceph/mon/#{cluster_node}/keyring") }
end

execute "make-ceph-mon-fs" do
  command %{ceph-mon --cluster #{node[:ceph][:cluster]} --mkfs -i #{node[:hostname]} --fsid #{node[:ceph][:config][:fsid]} --keyring "#{keyring}"}
  creates "/var/lib/ceph/mon/#{cluster_node}/keyring"
  notifies :start, "service[ceph]", :immediately
end

file keyring do
  action :delete
end

ruby_block "tell ceph-mon about its peers" do
  block do
    mon_addresses = get_mon_addresses
    mon_addresses.each do |addr|
      system 'ceph', \
        '--admin-daemon', "/var/run/ceph/ceph-mon.#{node[:hostname]}.asok", \
        'add_bootstrap_peer_hint', addr
    end
  end
end

ruby_block "create and save client.admin key" do
  only_if { node['ceph_client_admin_key'].nil? }
  block do
    if not have_quorum? then
      puts 'ceph-mon is not in quorum, skipping client.admin key generation for this run'
    else
      key = %x[
        ceph \
          --name mon. \
          --keyring '/var/lib/ceph/mon/ceph-#{node[:hostname]}/keyring' \
          auth get-or-create-key client.admin \
          mon 'allow *' \
          mds 'allow *' \
          osd 'allow *'
      ].chomp
      raise 'adding or getting client.admin key failed' unless $?.exitstatus == 0
      node.override['ceph_client_admin_key'] = key
      node.save
    end
  end
end
