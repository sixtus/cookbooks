# this nodes chef environment
default[:classification] = :normal

# make the primary IP address overridable
default[:primary_ipaddress] = node[:ipaddress]
default[:primary_ip6address] = nil

# ec2 support
if node[:ec2] and node[:ec2][:local_ipv4]
  default[:bind_ipaddress] = node[:ec2][:local_ipv4]
else
  default[:bind_ipaddress] = node[:primary_ipaddress]
end

# cluster support
default[:cluster][:name] = "default"

# detect network interfaces
node[:network][:interfaces].each do |name, int|
  next unless int[:addresses]
  if int[:addresses].keys.include?(node[:primary_ipaddress])
    set[:primary_interface] = name
    break
  end
end

# legacy support for local networks
default[:local_ipaddress] = nil

if node[:local_ipaddress]
  node[:network][:interfaces].each do |name, int|
    next unless int[:addresses]
    if int[:addresses].keys.include?(node[:local_ipaddress])
      set[:local_interface] = name
      break
    end
  end
end

# this is automatically inferred from the Chef servers domain by default but
# may be overridden on a per-role or per-node basis
default[:contacts][:hostmaster] = "hostmaster@#{node[:chef_domain]}"

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

# kernel options
default[:sysctl][:kernel][:sysrq] = 1
default[:sysctl][:kernel][:panic] = 60

# virtual memory options
default[:sysctl][:vm][:overcommit_ratio] = 95
default[:sysctl][:vm][:overcommit_memory] = 0

# shared memory sizes
default_unless[:sysctl][:kernel][:shmall] = 2*1024*1024 #pages
default_unless[:sysctl][:kernel][:shmmax] = 32*1024*1024 #bytes
default_unless[:sysctl][:kernel][:shmmni] = 4096

# network tuning
default[:sysctl][:net][:core][:somaxconn] = 128
default[:sysctl][:net][:ipv4][:ip_local_port_range] = "32768 61000"
default[:sysctl][:net][:ipv4][:tcp_fin_timeout] = 60
default[:sysctl][:net][:ipv4][:tcp_max_syn_backlog] = 2048
default[:sysctl][:net][:ipv4][:tcp_syncookies] = 1
default[:sysctl][:net][:ipv4][:tcp_tw_recycle] = 0
default[:sysctl][:net][:ipv4][:tcp_tw_reuse] = 0
default[:sysctl][:net][:ipv4][:tcp_window_scaling] = 1
default[:sysctl][:net][:ipv4][:tcp_timestamps] = 1
default[:sysctl][:net][:netfilter][:nf_conntrack_max] = 262144
default[:sysctl][:net][:netfilter][:nf_conntrack_tcp_timeout_time_wait] = 120
default[:sysctl][:net][:netfilter][:nf_conntrack_tcp_timeout_established] = 432000

# vrtualization foo
default[:virtualization][:role] = "host"
default[:skip][:hardware] = node[:virtualization][:role] == "guest"

# provide sane default values in case ohai didn't find them
default_unless[:cpu][:total] = 1
default_unless[:virtualization] = {}
set[:virtualization][:guests] = %x(vserver-stat 2>/dev/null | wc -l).chomp.to_i

# support non-root runs
if root?
  default[:homedir] = "/root"
  default[:current_email] = "root@localhost"
  default[:current_name] = "Hostmaster of the day"
  default[:script_path] = "/usr/local/bin"
else
  default[:homedir] = node[:etc][:passwd][node[:current_user]][:dir]
  default[:current_email] = "#{node[:current_user]}@localhost"
  default[:current_name] = node[:current_user]
  default[:script_path] = "#{node[:homedir]}/bin"
end

# base packages
case node[:platform]
when "gentoo"
  node.set[:packages] = %w(
    app-admin/apache-tools
    app-admin/pwgen
    app-admin/pydf
    app-admin/sysstat
    app-arch/atool
    app-arch/xz-utils
    app-misc/colordiff
    app-misc/mc
    app-shells/bash-completion
    app-text/dos2unix
    dev-libs/icu
    dev-libs/libffi
    dev-libs/libxml2
    dev-libs/libxslt
    dev-libs/libyaml
    dev-ruby/haml
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
    sys-process/iotop
    sys-process/lsof
  )

when "mac_os_x"
  node.set[:packages] = %w(
    ack
    apple-gcc42
    atool
    autoconf
    automake
    colordiff
    dos2unix
    findutils
    gawk
    gnu-sed
    gnu-tar
    icu4c
    keychain
    libffi
    libksba
    libtool
    libxml2
    libxslt
    libyaml
    ncdu
    netcat
    nmap
    openssl
    pkg-config
    pwgen
    readline
    sqlite
    wget
  )
end
