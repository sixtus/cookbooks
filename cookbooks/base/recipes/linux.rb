if root?
  # create accounts first so we can login if
  # initial chef-client run fails for some reason
  include_recipe "account"
  include_recipe "base::etcgit"
  include_recipe "base::locales"
  include_recipe "base::resolv"
  include_recipe "base::sysctl"
  include_recipe "baselayout"
  include_recipe "systemd"

  # load distro specific base recipe
  include_recipe "base::#{node[:platform]}"

  # install base packages
  node[:packages].each do |pkg|
    package pkg
  end

  cookbook_file "/usr/local/bin/service" do
    source "service.sh"
    owner "root"
    group "root"
    mode "0755"
  end

  include_recipe "lib_users"
  include_recipe "openssl"
  include_recipe "nss"
  include_recipe "sudo"
  include_recipe "ssh::server"
  include_recipe "postfix"
  include_recipe "cron"
  include_recipe "syslog"

  # these are only usefull in non-solo mode and only if the specified role
  # has been deployed on another node (see above)
  if node.run_state[:chef].any?
    include_recipe "chef::client"
  end

  if node.run_state[:splunk].any?
    include_recipe "splunk::forwarder"
    include_recipe "ganymed"
  end

  if node.run_state[:mx].any?
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

  if root?
    include_recipe "duply"
  end
end

if tagged?("nagios-client")
  include_recipe "nagios::client"

  nagios_service "PING" do
    check_command "check_ping!250.0,20%!500.0,60%"
    servicegroups "system"
    env [:staging, :testing, :development]
  end

  nrpe_command "check_zombie_procs" do
    command "/usr/lib/nagios/plugins/check_procs -w 5 -c 10 -s Z"
  end

  nagios_service "ZOMBIES" do
    check_command "check_nrpe!check_zombie_procs"
    servicegroups "system"
    env [:staging, :testing, :development]
  end

  nrpe_command "check_total_procs" do
    command "/usr/lib/nagios/plugins/check_procs -w 300 -c 1000"
  end

  nagios_service "PROCS" do
    check_command "check_nrpe!check_total_procs"
    servicegroups "system"
    env [:staging]
  end

  unless node[:skip][:hardware]
    nagios_plugin "check_raid"

    nrpe_command "check_raid" do
      command "/usr/lib/nagios/plugins/check_raid"
    end

    nagios_service "RAID" do
      check_command "check_nrpe!check_raid"
      servicegroups "system"
      env [:staging, :testing, :development]
    end

    nagios_plugin "check_mem"

    nrpe_command "check_mem" do
      command "/usr/lib/nagios/plugins/check_mem -C -u -w 80 -c 95"
    end

    nagios_service "MEMORY" do
      check_command "check_nrpe!check_mem"
      servicegroups "system"
      env [:staging, :testing, :development]
    end

    nrpe_command "check_load" do
      command "/usr/lib/nagios/plugins/check_load -w #{node[:cpu][:total]*3} -c #{node[:cpu][:total]*10}"
    end

    nagios_service "LOAD" do
      check_command "check_nrpe!check_load"
      servicegroups "system"
      env [:staging, :testing, :development]
    end

    nrpe_command "check_disks" do
      command "/usr/lib/nagios/plugins/check_disk -w 10% -c 5% -A -i /var/tmp/metro"
    end

    nagios_service "DISKS" do
      check_command "check_nrpe!check_disks"
      notification_interval 15
      servicegroups "system"
      env [:staging, :testing, :development]
    end

    nrpe_command "check_swap" do
      command "/usr/lib/nagios/plugins/check_swap -w 75% -c 50%"
    end

    nagios_service "SWAP" do
      check_command "check_nrpe!check_swap"
      notification_interval 180
      servicegroups "system"
      env [:staging, :testing, :development]
    end

    sudo_rule "nagios-ethtool" do
      user "nagios"
      runas "root"
      command "NOPASSWD: /usr/sbin/ethtool"
      command "NOPASSWD: /sbin/ethtool" if node[:platform] == "debian"
    end

    nagios_plugin "check_link_usage"

    nrpe_command "check_link_usage" do
      command "/usr/lib/nagios/plugins/check_link_usage"
    end

    nagios_service "LINK" do
      check_command "check_nrpe!check_link_usage"
      servicegroups "system"
      check_interval 10
      env [:staging, :testing, :development]
    end

    execute "check_link_usage" do
      command "/usr/lib/nagios/plugins/check_link_usage"
      creates "/tmp/.check_link_usage.eth0:"
      user "nagios"
      group "nagios"
    end
  end
end
