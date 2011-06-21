# this nodes chef environment
default[:chef_environment] = "production"

# cluster support
default[:cluster][:name] = "default"

# this should be overriden globally or per-role
default[:contacts][:hostmaster] = "root@#{node[:fqdn]}"

# localization/i18n
default[:timezone] = "Europe/Berlin"
default[:locales] = [
  "en_US.UTF-8 UTF-8",
  "de_DE.UTF-8 UTF-8",
]

# custom /etc/hosts entries
default[:base][:additional_hosts] = []

# nameservers and search domain
default[:resolv][:search] = [node[:domain]]
default[:resolv][:nameservers] = %w(8.8.8.8 8.8.4.4)

# sysctl attributes
default[:sysctl][:net][:ipv4][:ip_forward] = 0
default[:sysctl][:net][:netfilter][:nf_conntrack_max] = 262144
default[:sysctl][:kernel][:sysrq] = 1
default[:sysctl][:kernel][:panic] = 60

# shared memory sizes
default_unless[:sysctl][:kernel][:shmall] = 2*1024*1024 #pages
default_unless[:sysctl][:kernel][:shmmax] = 32*1024*1024 #bytes
default_unless[:sysctl][:kernel][:shmmni] = 4096

# base packages
node[:packages] = %w(
  app-admin/lib_users
  app-admin/pwgen
  app-admin/pydf
  app-admin/superadduser
  app-arch/atool
  app-arch/xz-utils
  app-misc/colordiff
  app-misc/mc
  app-misc/tmux
  app-shells/bash-completion
  mail-client/mailx
  net-analyzer/bwm-ng
  net-analyzer/iptraf-ng
  net-analyzer/mtr
  net-analyzer/netcat
  net-analyzer/tcpdump
  net-analyzer/traceroute
  net-dns/bind-tools
  net-misc/keychain
  net-misc/rsync
  net-misc/telnet-bsd
  net-misc/wget
  net-misc/whois
  sys-apps/iproute2
  sys-apps/pciutils
  sys-fs/ncdu
  sys-process/htop
  sys-process/iotop
  sys-process/lsof
)

# block upgrades with p.mask entries
default[:gentoo][:upgrade_blockers] = []

# backwards compatibility (ohai-0.6 introduces linux-vserver detection)
if File.exists?("/proc/self/vinfo")
  set[:virtualization][:emulator] = "linux-vserver"
  set[:virtualization][:system] = "linux-vserver"
  if File.exists?("/proc/virtual")
    set[:virtualization][:role] = "host"
  else
    set[:virtualization][:role] = "guest"
  end
else
  set[:virtualization][:role] = "host"
end

# rc_sys
if node[:virtualization][:role] == "guest"
  default[:openrc][:sys] = case node[:virtualization][:system]
                             when "linux-vserver"
                               "vserver"
                             else
                               raise "Unsupported virtualization system: #{node[:virtualization][:system]}"
                             end
else
  default[:openrc][:sys] = ""
end
