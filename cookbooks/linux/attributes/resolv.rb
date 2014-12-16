default[:resolv][:nameservers] = %w(8.8.8.8 8.8.4.4)

%x(whois #{node[:ipaddress]} | grep -q HETZNER-RZ)
default[:resolv][:nameservers] = %w(213.133.98.98 213.133.99.99) if $?.exitstatus == 0

default[:resolv][:search] = []
default[:resolv][:hosts] = []
default[:resolv][:aliases] = []
