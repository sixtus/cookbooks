# kernel options
default[:sysctl][:kernel][:panic] = 60

# open files/sockets
default[:sysctl][:fs][:nr_open] = 1048576

# network tuning
default[:sysctl][:net][:core][:somaxconn] = 1024
default[:sysctl][:net][:core][:netdev_max_backlog] = 10000
default[:sysctl][:net][:ipv4][:ip_local_port_range] = "32768 65535"
default[:sysctl][:net][:ipv4][:tcp_fin_timeout] = 5
default[:sysctl][:net][:ipv4][:tcp_sack] = 0
default[:sysctl][:net][:ipv4][:tcp_syncookies] = 1
default[:sysctl][:net][:ipv4][:tcp_timestamps] = 1
default[:sysctl][:net][:ipv4][:tcp_tw_recycle] = 0
default[:sysctl][:net][:ipv4][:tcp_tw_reuse] = 0
default[:sysctl][:net][:netfilter][:nf_conntrack_max] = 4194304
