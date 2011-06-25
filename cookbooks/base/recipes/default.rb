# to make things faster, add the node list to our run_state for later use
node.run_state[:nodes] = search(:node, "ipaddress:[* TO *]")

# load ohai plugins first
include_recipe "ohai"

# load base recipes
include_recipe "portage"
include_recipe "portage::porticron"
include_recipe "git"
include_recipe "lftp"
include_recipe "tmux"
include_recipe "vim"

# install base packages
node[:packages].each do |pkg|
  package pkg
end

# initialize /etc with git to keep track of changes
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
    "env.exclude none unknown iso9660 squashfs udf romfs ramfs debugfs simfs rootfs rc-svcdir udev shm",
    "env.warning 90",
    "env.critical 95"
  ]
end

if node[:virtualization][:role] == "host"
  munin_plugin "iostat"
  munin_plugin "swap"
  munin_plugin "vmstat"
end

# reset all attributes to make sure cruft is being deleted on chef-client run
node.default[:nagios][:services] = {}

nagios_service "PING" do
  check_command "check_ping!100.0,20%!500.0,60%"
  servicegroups "system"
end

nagios_service "ZOMBIES" do
  check_command "check_munin_single!processes!zombie!5!10"
  servicegroups "system"
end

nagios_service "PROCS" do
  check_command "check_munin!processes!300!1000"
  servicegroups "system"
end

if node[:virtualization][:role] == "host"
  nagios_plugin "raid" do
    source "check_raid"
  end

  nrpe_command "check_raid" do
    command "/usr/lib/nagios/plugins/check_raid"
  end

  nagios_service "RAID" do
    check_command "check_nrpe!check_raid"
    servicegroups "system"
  end

  nagios_service "LOAD" do
    check_command "check_munin!load!#{node[:cpu][:total]*3}!#{node[:cpu][:total]*10}"
    servicegroups "system"
  end

  nagios_service "DISKS" do
    check_command "check_munin!df!90!95"
    notification_interval 15
    servicegroups "system"
  end

  nagios_service_escalation "DISKS" do
    notification_interval 15
  end

  nagios_service "SWAP" do
    check_command "check_munin!swap!128!1024"
    notification_interval 180
    servicegroups "system"
  end
end
