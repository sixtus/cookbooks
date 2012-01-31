# this nodes chef environment
default[:chef_environment] = "production"
default[:classification] = :normal

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

# nameservers and search domain
default[:resolv][:search] = [node[:domain]]
default[:resolv][:nameservers] = %w(8.8.8.8 8.8.4.4)
default[:resolv][:hosts] = []
default[:resolv][:aliases] = []

# sysctl attributes
default[:sysctl][:net][:ipv4][:ip_forward] = 0
default[:sysctl][:net][:netfilter][:nf_conntrack_max] = 262144
default[:sysctl][:kernel][:sysrq] = 1
default[:sysctl][:kernel][:panic] = 60
default[:sysctl][:vm][:overcommit_ratio] = 95
default[:sysctl][:vm][:overcommit_memory] = 0

# shared memory sizes
default_unless[:sysctl][:kernel][:shmall] = 2*1024*1024 #pages
default_unless[:sysctl][:kernel][:shmmax] = 32*1024*1024 #bytes
default_unless[:sysctl][:kernel][:shmmni] = 4096

# skip hardware cookbooks
default[:skip][:hardware] = false

# provide sane default values in case ohai didn't find them
default_unless[:virtualization] = {}
default_unless[:cpu][:total] = 1

# support non-root runs
if Process.euid == 0
  default[:homedir] = "/root"
  default[:current_email] = "root@localhost"
  default[:current_name] = "Hostmaster of the day"
else
  default[:homedir] = node[:etc][:passwd][node[:current_user]][:dir]
  default[:current_email] = "#{node[:current_user]}@localhost"
  default[:current_name] = node[:current_user]
end

# base packages
case node[:platform]
when "gentoo"
  node[:packages] = %w(
    app-admin/lib_users
    app-admin/pwgen
    app-admin/pydf
    app-admin/sysstat
    app-arch/atool
    app-arch/xz-utils
    app-misc/colordiff
    app-misc/mc
    app-shells/bash-completion
    app-text/dos2unix
    dev-libs/libyaml
    dev-util/strace
    mail-client/mailx
    net-analyzer/bwm-ng
    net-analyzer/iptraf-ng
    net-analyzer/mtr
    net-analyzer/netcat
    net-analyzer/nmap
    net-analyzer/tcpdump
    net-analyzer/tcptraceroute
    net-analyzer/traceroute
    net-dns/bind-tools
    net-misc/keychain
    net-misc/telnet-bsd
    net-misc/whois
    sys-apps/ack
    sys-apps/ethtool
    sys-apps/hdparm
    sys-apps/iproute2
    sys-apps/less
    sys-apps/pciutils
    sys-fs/ncdu
    sys-process/htop
    sys-process/iotop
    sys-process/lsof
  )

  if node[:virtualization][:role] == "host"
    node[:packages] += %w(
      sys-kernel/genkernel
    )
  end

when "mac_os_x"
  # coreutils is missing xz dependency
  node[:packages] = %w(xz coreutils)

  node[:packages] += %w(
    ack
    atool
    bwm-ng
    colordiff
    dos2unix
    findutils
    gawk
    gnu-sed
    gnu-tar
    keychain
    libyaml
    midnight-commander
    ncdu
    netcat
    nmap
    proctools
    pwgen
    ssh-copy-id
    wget
  )
end
