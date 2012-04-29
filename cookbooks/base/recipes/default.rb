# to make things faster, load data from search index into run_state
if solo?
  node.run_state[:nodes] = []
  node.run_state[:roles] = []
  node.run_state[:users] = []
else
  node.run_state[:nodes] = search(:node, "ipaddress:[* TO *]")
  node.run_state[:roles] = search(:role)
  node.run_state[:users] = search(:users)
end

# figure out if we're a nagios/munin client first, so recipes can conditionally
# install nagios/munin plugins
nagios_masters = node.run_state[:nodes].select do |n|
  n[:tags].include?("nagios-master")
end

if nagios_masters.any?
  tag("nagios-client")
end

munin_masters = node.run_state[:nodes].select do |n|
  n[:tags].include?("munin-master")
end

if munin_masters.any?
  tag("munin-node")
end

# create script path
directory node[:script_path] do
  owner node[:current_user]
  mode "0755"
end

# load platform specific base recipes
case node[:platform]

when "gentoo"
  if root?
    include_recipe "ohai"
    include_recipe "base::etcgit"
    include_recipe "base::locales"
    include_recipe "base::resolv"
    include_recipe "base::sysctl"
    include_recipe "baselayout"
    include_recipe "sysvinit"
    include_recipe "openrc"
    include_recipe "portage"
    include_recipe "portage::porticron"
    include_recipe "openssl"
    include_recipe "nss"
    include_recipe "syslog::client"
    include_recipe "cron"
    include_recipe "sudo"
    include_recipe "ssh::server"

    if tagged?("nagios-client")
      include_recipe "nagios::client"
    end

    if tagged?("munin-node")
      include_recipe "munin::node"
    end
  end

when "mac_os_x"
  raise "running as root is not supported on mac os" if root?
  include_recipe "homebrew"

end

# install base packages
node[:packages].each do |pkg|
  package pkg
end

# load common recipes
include_recipe "bash"
include_recipe "git"
include_recipe "lftp"
include_recipe "ssh"
include_recipe "tmux"
include_recipe "vim"

# vservers don't have hardware access
if root? and node[:os] == "linux" and node[:virtualization][:role] == "host" and not node[:skip][:hardware]
  include_recipe "hwraid"
  include_recipe "mdadm"
  include_recipe "ntp"
  include_recipe "shorewall"
  include_recipe "smart"
end

# use account cookbook in root mode
include_recipe "account" if root?

# enable munin plugins
if tagged?("munin-node")
  munin_plugin "cpu"
  munin_plugin "entropy"
  munin_plugin "forks"
  munin_plugin "load"
  munin_plugin "memory"
  munin_plugin "open_files"
  munin_plugin "open_inodes"
  munin_plugin "processes"

  munin_plugin "df" do
    source "df"
    config [
      "env.warning 90",
      "env.critical 95"
    ]
  end

  if node[:virtualization][:role] == "host"
    munin_plugin "iostat"
    munin_plugin "swap"
    munin_plugin "vmstat"
  end
end

if tagged?("nagios-client")
  nagios_service "PING" do
    check_command "check_ping!100.0,20%!500.0,60%"
    servicegroups "system"
  end

  nrpe_command "check_zombie_procs" do
    command "/usr/lib/nagios/plugins/check_procs -w 5 -c 10 -s Z"
  end

  nagios_service "ZOMBIES" do
    check_command "check_nrpe!check_zombie_procs"
    servicegroups "system"
  end

  nrpe_command "check_total_procs" do
    command "/usr/lib/nagios/plugins/check_procs -w 300 -c 1000"
  end

  nagios_service "PROCS" do
    check_command "check_nrpe!check_total_procs"
    servicegroups "system"
  end

  sudo_rule "nagios-lib_users" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /usr/bin/lib_users"
  end

  nagios_plugin "check_lib_users"

  nrpe_command "check_lib_users" do
    command "/usr/lib/nagios/plugins/check_lib_users"
  end

  nagios_service "LIB-USERS" do
    check_command "check_nrpe!check_lib_users"
    servicegroups "system"
    notifications_enabled 0
  end

  if node[:virtualization][:role] == "host"
    nagios_plugin "check_raid"

    nrpe_command "check_raid" do
      command "/usr/lib/nagios/plugins/check_raid"
    end

    nagios_service "RAID" do
      check_command "check_nrpe!check_raid"
      servicegroups "system"
    end

    nrpe_command "check_load" do
      command "/usr/lib/nagios/plugins/check_load -w #{node[:cpu][:total]*3} -c #{node[:cpu][:total]*10}"
    end

    nagios_service "LOAD" do
      check_command "check_nrpe!check_load"
      servicegroups "system"
    end

    nrpe_command "check_disks" do
      command "/usr/lib/nagios/plugins/check_disk -w 10% -c 5%"
    end

    nagios_service "DISKS" do
      check_command "check_nrpe!check_disks"
      notification_interval 15
      servicegroups "system"
    end

    nagios_service_escalation "DISKS"

    nrpe_command "check_swap" do
      command "/usr/lib/nagios/plugins/check_swap -w 75% -c 50%"
    end

    nagios_service "SWAP" do
      check_command "check_nrpe!check_swap"
      notification_interval 180
      servicegroups "system"
    end

    nagios_plugin "check_link_usage"

    nrpe_command "check_link_usage" do
      command "/usr/lib/nagios/plugins/check_link_usage"
    end

    nagios_service "LINK" do
      check_command "check_nrpe!check_link_usage"
      servicegroups "system"
      check_interval 10
    end

    execute "check_link_usage" do
      command "/usr/lib/nagios/plugins/check_link_usage"
      creates "/tmp/.check_link_usage.lo:"
      user "nagios"
      group "nagios"
    end
  end
end
