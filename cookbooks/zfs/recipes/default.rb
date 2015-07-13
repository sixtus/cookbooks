if gentoo?
  package "sys-fs/zfs"

  %w{
   mount_zpools
   unmount_zpools
  }.each do |file|
    cookbook_file "/etc/zfs/#{file}" do
      source file
      owner "root"
      group "root"
      mode "0544"
    end
  end

  systemd_unit "zfs.service" do
    template true
  end

  service "zfs" do
    action [:enable, :start]
  end
end

# check if quickstart has left us zpool setup instructions
bash "zpool-create" do
  code "set -e; source /zpool-create.sh"
  only_if { File.exist?("/zpool-create.sh") }
end

file "/zpool-create.sh" do
  action :delete
end

zfs_pools = %x{/sbin/zpool list -Ho name}.split("\n") rescue []

# write the initial set of zfs pools to the node
# this helps defend against failure to mount leading to removing the checks
if !zfs_pools.empty?
  if !node[:zfs] || !node[:zfs][:pools]
    node.set[:zfs][:pools] = zfs_pools
  end
end

# make sure the stored pools are part of the check list
zfs_pools = (zfs_pools + ((node[:zfs] && node[:zfs][:pools]) || [])).compact.uniq

if zfs_pools.any?
  include_recipe "zfs"

  zfs_pools.each do |name|
    systemd_timer "zfs-scrub-#{name}" do
      schedule %W(OnCalendar=weekly AccuracySec=1h)
      unit command: "/sbin/zpool scrub #{name}"
    end
  end

  if nagios_client?
    cookbook_file "/usr/lib/nagios/plugins/check_zfs" do
      source "check_zfs.pl"
      owner "root"
      group "root"
      mode "0777"
    end

    sudo_rule "nagios-check_zfs" do
      user "nagios"
      runas "root"
      command "NOPASSWD: /usr/lib/nagios/plugins/check_zfs"
    end
    sudo_rule "nagios-zpool" do
      user "nagios"
      runas "root"
      command "NOPASSWD: /sbin/zpool"
    end

    zfs_pools.each do |name|
      nrpe_command "check_zfs_#{name}" do
        command "/usr/lib/nagios/plugins/check_zfs #{name} 1"
      end unless name.nil?

      nagios_service "ZFS-POOL-#{name.upcase}" do
        check_command "check_nrpe!check_zfs_#{name}"
        servicegroups "system"
      end unless name.nil?
    end
  end
end
