# this nodes chef environment
default[:chef_environment] = "production"

# cluster support
default[:cluster][:name] = "default"

# this should be overriden globally or per-role
default[:contacts][:hostmaster] = "root@#{node[:fqdn]}"

# time zone
default[:timezone] = "Europe/Berlin"

# custom /etc/hosts entries
default[:base][:additional_hosts] = []

# ohai does not detect Linux-VServer
if File.exists?("/proc/self/vinfo")
  set[:virtualization][:emulator] = "vserver"
  if File.exists?("/proc/virtual")
    set[:virtualization][:role] = "host"
  else
    set[:virtualization][:role] = "guest"
  end
else
  set[:virtualization][:role] = "host"
end

# sysctl attributes
default[:sysctl][:net][:ipv4][:ip_forward] = 0
default[:sysctl][:net][:netfilter][:nf_conntrack_max] = 262144
default[:sysctl][:kernel][:sysrq] = 1
default[:sysctl][:kernel][:panic] = 60
