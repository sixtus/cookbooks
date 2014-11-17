default[:resolv][:nameservers] = %w(4.2.2.2 8.8.8.8)

%x(whois #{node[:ipaddress]} | grep -q HETZNER-RZ)
default[:resolv][:nameservers] = %w(213.133.98.98 213.133.99.99) if $?.exitstatus == 0

%x(whois #{node[:ipaddress]} | grep -q OVH)
default[:resolv][:nameservers] = %w(213.186.40.81 213.186.33.99) if $?.exitstatus == 0

default[:resolv][:search] = []
default[:resolv][:hosts] = []
default[:resolv][:aliases] = []
