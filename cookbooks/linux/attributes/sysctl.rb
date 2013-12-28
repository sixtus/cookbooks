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
