# make the primary IP address overridable
default[:primary_ipaddress] = node[:ipaddress] || "127.0.0.1"
default[:primary_ip6address] = nil

# cluster support
default[:chef_domain] = node[:domain]
default[:cluster][:name] = "default"

# contacts
default[:contacts][:hostmaster] = "hostmaster@#{node[:chef_domain]}"

# localization/i18n
default[:timezone] = "Europe/Berlin"
default[:locales] = [
  "en_US.UTF-8 UTF-8",
  "de_DE.UTF-8 UTF-8",
]

# nameservers and search domain
%x(whois #{node[:primary_ipaddress]} | grep -q HETZNER-RZ)
if $?.exitstatus == 0
  default[:resolv][:nameservers] = %w(213.133.98.98 213.133.99.99)
else
  default[:resolv][:nameservers] = %w(4.2.2.2 8.8.8.8)
end
default[:resolv][:search] = []
default[:resolv][:hosts] = []
default[:resolv][:aliases] = []

# kernel options
default[:sysctl][:kernel][:sysrq] = 1
default[:sysctl][:kernel][:panic] = 60

# virtual memory options
default[:sysctl][:vm][:overcommit_ratio] = 95
default[:sysctl][:vm][:overcommit_memory] = 0

# shared memory sizes
default_unless[:sysctl][:kernel][:shmall] = 4194304 # 2^22 = 4M
default_unless[:sysctl][:kernel][:shmmax] = 17179869184 # 2^34 = 16G
default_unless[:sysctl][:kernel][:shmmni] = 4096

# open files/sockets
default[:sysctl][:fs][:file_max] = 524288 # 2^19
default[:sysctl][:fs][:nr_open] = 262144 # 2^18

# network tuning
default[:sysctl][:net][:core][:somaxconn] = 128
default[:sysctl][:net][:core][:netdev_max_backlog] = 1000
default[:sysctl][:net][:core][:rmem_max] = 131071
default[:sysctl][:net][:core][:wmem_max] = 131071
default[:sysctl][:net][:ipv4][:ip_local_port_range] = "32768 61000"
default[:sysctl][:net][:ipv4][:tcp_fin_timeout] = 60
default[:sysctl][:net][:ipv4][:tcp_max_syn_backlog] = 2048
default[:sysctl][:net][:ipv4][:tcp_max_tw_buckets] = 262144
default[:sysctl][:net][:ipv4][:tcp_sack] = 1
default[:sysctl][:net][:ipv4][:tcp_syncookies] = 1
default[:sysctl][:net][:ipv4][:tcp_timestamps] = 1
default[:sysctl][:net][:ipv4][:tcp_tw_recycle] = 0
default[:sysctl][:net][:ipv4][:tcp_tw_reuse] = 0
default[:sysctl][:net][:ipv4][:tcp_window_scaling] = 1
default[:sysctl][:net][:ipv4][:tcp_rmem] = "4096 87380 6291456"
default[:sysctl][:net][:ipv4][:tcp_wmem] = "4096 16384 4194304"
default[:sysctl][:net][:netfilter][:nf_conntrack_max] = 262144
default[:sysctl][:net][:netfilter][:nf_conntrack_tcp_timeout_time_wait] = 120
default[:sysctl][:net][:netfilter][:nf_conntrack_tcp_timeout_established] = 432000

# virtualization foo
default[:virtualization][:role] = "host"
if gentoo?
  %x(systemd-detect-virt -q)
  default[:virtualization][:guest] = $?.exitstatus == 0
end
default[:skip][:hardware] = node[:virtualization][:guest]

# provide sane default values in case ohai didn't find them
default_unless[:cpu][:total] = 1
default_unless[:virtualization] = {}

# support non-root runs
if root?
  default[:homedir] = "/root"
  default[:current_email] = "root@localhost"
  default[:current_name] = "Hostmaster of the day"
  default[:script_path] = "/usr/local/bin"
else
  default[:homedir] = node[:etc][:passwd][node[:current_user]][:dir]
  default[:current_email] = "#{node[:current_user]}@#{node[:fqdn]}"
  default[:current_name] = node[:etc][:passwd][node[:current_user]][:gecos]
  default[:script_path] = "#{node[:homedir]}/bin"
end

# ec2 support
if node[:ec2] and node[:ec2][:local_ipv4]
  default[:bind_ipaddress] = node[:ec2][:local_ipv4]
else
  default[:bind_ipaddress] = node[:primary_ipaddress]
end

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
