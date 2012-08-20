tag('ceph-mon')

include_recipe "ceph::default"
include_recipe "ceph::conf"

ipaddress = node[:ipaddress]

service "ceph" do
  action [:enable]
end

cluster_node = "ceph-#{node[:hostname]}"
keyring = "/var/lib/ceph/tmp/#{cluster_node}.mon.keyring"

execute "create-ceph-keyring" do
  command %{ceph-authtool "#{keyring}" --create-keyring --name=mon. --add-key='#{node[:ceph][:monitor_secret]}' --cap mon 'allow *'}
  not_if { File.exist?("/var/lib/ceph/mon/#{cluster_node}/keyring") }
end

execute "make-ceph-mon-fs" do
  command %{ceph-mon --mkfs -i #{node[:hostname]} --fsid #{node[:ceph][:config][:fsid]} --keyring "#{keyring}"}
  creates "/var/lib/ceph/mon/#{cluster_node}/keyring"
  notifies :start, "service[ceph]", :immediately
end

file keyring do
  action :delete
end

ruby_block "tell ceph-mon about its peers" do
  block do
    mon_addresses = get_mon_addresses()
    mon_addresses.each do |addr|
      system 'ceph', \
        '--admin-daemon', "/var/run/ceph/ceph-mon.#{node[:hostname]}.asok", \
        'add_bootstrap_peer_hint', addr
    end
  end
end

ruby_block "create client.admin keyring" do
  block do
    if not ::File.exists?('/etc/ceph/ceph.client.admin.keyring') then
      if not have_quorum? then
        puts 'ceph-mon is not in quorum, skipping bootstrap-osd key generation for this run'
      else
        # TODO --set-uid=0
        key = %x[
        ceph \
          --name mon. \
          --keyring '/var/lib/ceph/mon/ceph-#{node[:hostname]}/keyring' \
          auth get-or-create-key client.admin \
          mon 'allow *' \
          osd 'allow *' \
          mds allow
        ]
        raise 'adding or getting admin key failed' unless $?.exitstatus == 0

        system 'ceph-authtool', \
          '/etc/ceph/ceph.client.admin.keyring', \
          '--create-keyring', \
          '--name=client.admin', \
          "--add-key=#{key}"
        raise 'creating admin keyring failed' unless $?.exitstatus == 0
      end
    end
  end
end

ruby_block "save osd bootstrap key in node attributes" do
  block do
    if node['ceph_bootstrap_osd_key'].nil? then
      if not have_quorum? then
        puts 'ceph-mon is not in quorum, skipping bootstrap-osd key generation for this run'
      else
        key = %x[
          ceph \
            --name mon. \
            --keyring '/var/lib/ceph/mon/#{cluster}-#{node['hostname']}/keyring' \
            auth get-or-create-key client.bootstrap-osd mon \
            "allow command osd create ...; \
            allow command osd crush set ...; \
            allow command auth add * osd allow\\ * mon allow\\ rwx; \
            allow command mon getmap"
        ]
        raise 'adding or getting bootstrap-osd key failed' unless $?.exitstatus == 0
        node.override['ceph_bootstrap_osd_key'] = key
        node.save
      end
    end
  end
end
