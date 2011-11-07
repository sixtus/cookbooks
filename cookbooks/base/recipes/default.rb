# to make things faster, add the node list to our run_state for later use
begin
  node.run_state[:nodes] = search(:node, "ipaddress:[* TO *]")
  node.run_state[:roles] = search(:role)
  node.run_state[:users] = search(:users)
rescue Chef::Exceptions::PrivateKeyMissing
  # chef-solo does not have search access
  node.run_state[:nodes] = []
  node.run_state[:roles] = []
  node.run_state[:users] = []
end

# load ohai plugins first
include_recipe "ohai"

# initialize /etc with git to keep track of changes
include_recipe "git"

execute "git init" do
  cwd "/etc"
  creates "/etc/.git"
end

directory "/etc/.git" do
  owner "root"
  group "root"
  mode "0700"
end

file "/etc/.gitignore" do
  content <<-EOS
*~
adjtime
config-archive
hosts.deny*
ld.so.cache
mtab
resolv*
EOS
  owner "root"
  group "root"
  mode "0644"
end

bash "commit changes to /etc" do
  code <<-EOS
cd /etc
git add -A .
git commit -m 'automatic commit during chef-client run'
git gc
EOS
  not_if { %x(env GIT_DIR=/etc/.git GIT_WORK_TREE=/etc git status --porcelain).strip.empty? }
end

# ensure that system users/groups from baselayout are always correct
# (just in case somebody has given login shells to system accounts etc)
node[:base][:groups].each do |name, params|
  group name do
    gid params[:gid]
    members params[:members].split(",")
  end
end

group "wheel" do
  gid 10
  append true
  members %w(root)
end

group "users" do
  gid 100
  append true
end

node[:base][:users].each do |name, params|
  comment = if params[:comment]
              params[:comment]
            else
              name
            end

  user name do
    password "*"
    uid params[:uid]
    gid params[:gid]
    comment comment
    home params[:home]
    shell params[:shell]
  end
end

# special case: for chef-solo runs we don't touch roots password, since we
# don't have any other user databags that could have sudo
user "root" do
  uid 0
  gid 0
  comment "root"
  home "/root"
  shell "/bin/bash"
  password "*" unless node.run_state[:users].empty?
end

# load base recipes
include_recipe "portage"
include_recipe "portage::porticron"
include_recipe "openssl"
include_recipe "lftp"
include_recipe "tmux"
include_recipe "vim"

# install base packages
node[:packages].each do |pkg|
  package pkg
end

# configure the resolver
template "/etc/hosts" do
  owner "root"
  group "root"
  mode "0644"
  source "hosts"
  variables :nodes => node.run_state[:nodes]
end

template "/etc/resolv.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "resolv.conf"
end

# configure and update sysctl/init
if node[:virtualization][:role] == "guest" and node[:virtualization][:system] == "linux-vserver"
  execute "sysctl-reload" do
    command "/bin/true"
    action :nothing
  end

  execute "init-reload" do
    command "/bin/true"
    action :nothing
  end
else
  execute "sysctl-reload" do
    command "/sbin/sysctl -p /etc/sysctl.conf"
    action :nothing
  end

  execute "init-reload" do
    command "/sbin/telinit q"
    action :nothing
  end
end

template "/etc/sysctl.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "sysctl.conf"
  notifies :run, "execute[sysctl-reload]"
end

template "/etc/inittab" do
  owner "root"
  group "root"
  mode "0644"
  source "inittab"
  notifies :run, "execute[init-reload]"
  backup 0
end

# localization/i18n
link "/etc/localtime" do
  to "/usr/share/zoneinfo/#{node[:timezone]}"
end

execute "locale-gen" do
  command "/usr/sbin/locale-gen"
  action :nothing
end

template "/etc/locale.gen" do
  owner "root"
  group "root"
  mode "0644"
  source "locale.gen"
  notifies :run, "execute[locale-gen]"
end

# TODO: move to account cookbook
%w(/root /root/.ssh).each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode "0700"
  end
end

# these links are missing in udev
link "/dev/fd" do
  to "/proc/self/fd"
end

link "/dev/stdin" do
  to "/dev/fd/0"
end

link "/dev/stdout" do
  to "/dev/fd/1"
end

link "/dev/stderr" do
  to "/dev/fd/2"
end

# configure openrc
template "/etc/rc.conf" do
  source "rc.conf"
  owner "root"
  group "root"
  mode "0644"
end

%w(shutdown reboot).each do |t|
  template "/etc/init.d/#{t}.sh" do
    source "#{t}.sh"
    mode "0755"
    backup 0
  end
end

%w(hostname hwclock).each do |f|
  template "/etc/conf.d/#{f}" do
    source "#{f}.confd"
    mode "0644"
    backup 0
  end
end

%w(
  /etc/conf.d/local
  /etc/init.d/net.lo
  /etc/init.d/net.eth0
  /etc/init.d/net.eth1
  /etc/runlevels/boot/net.lo
  /etc/runlevels/boot/net.eth0
  /etc/runlevels/boot/net.eth1
  /etc/runlevels/default/net.lo
  /etc/runlevels/default/net.eth0
  /etc/runlevels/default/net.eth1
  /etc/conf.d/net
).each do |f|
  file f do
    action :delete
    backup 0
  end
end

%w(devfs dmesg udev).each do |f|
  link "/etc/runlevels/sysinit/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

%w(
  bootmisc
  consolefont
  fsck
  hostname
  hwclock
  keymaps
  localmount
  modules
  mtab
  network
  procfs
  root
  swap
  sysctl
  termencoding
  urandom
).each do |f|
  link "/etc/runlevels/boot/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

%w(local netmount).each do |f|
  link "/etc/runlevels/default/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

%w(killprocs mount-ro savecache).each do |f|
  link "/etc/runlevels/shutdown/#{f}" do
    to "/etc/init.d/#{f}"
  end
end

# vservers don't have hardware access
if node[:virtualization][:role] == "host" and not node[:skip][:hardware]
  include_recipe "hwraid"
  include_recipe "mdadm"
  include_recipe "ntp"
  include_recipe "shorewall"
  include_recipe "smart"
end

# enable munin plugins
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
