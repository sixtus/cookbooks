if root?
  include_recipe "linux::baselayout"
  include_recipe "linux::locales"
  include_recipe "linux::resolv"
  include_recipe "linux::sysctl"
  include_recipe "linux::#{node[:platform]}"
  include_recipe "linux::packages"
  include_recipe "systemd"

  file "/usr/local/bin/service" do
    action :delete
  end

  file "/sbin/service" do
    action :delete
    only_if { File.symlink?("/sbin/service") }
  end

  cookbook_file "/sbin/service" do
    source "service.sh"
    owner "root"
    group "root"
    mode "0755"
  end

  if !solo?
    include_recipe "chef::client"
  end

  if splunk_nodes.any?
    include_recipe "splunk::forwarder"
  end

  if ganymed?
    include_recipe "ganymed"
  end

  if !solo?
    include_recipe "postfix::satelite" unless node[:skip][:postfix_satelite]
  end

  unless node[:virtualization][:guest]
    include_recipe "libvirt"
    include_recipe "ntp"
  end

  if !vbox_guest? and !node[:skip][:shorewall]
    include_recipe "shorewall"
  end

  cron_daily "xfs_fsr" do
    command "/usr/sbin/xfs_fsr -t 600"
    action :delete if node[:skip][:hardware]
  end

  unless node[:skip][:hardware]
    include_recipe "hwraid"
    include_recipe "mdadm"
    include_recipe "smart"
    include_recipe "watchdog"
  end

  include_recipe "duply"
end

include_recipe "linux::nagios"
