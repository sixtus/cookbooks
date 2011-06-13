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

# sysctl attributes
default[:sysctl][:net][:ipv4][:ip_forward] = 0
default[:sysctl][:net][:netfilter][:nf_conntrack_max] = 262144
default[:sysctl][:kernel][:sysrq] = 1
default[:sysctl][:kernel][:panic] = 60

# shared memory sizes
default_unless[:sysctl][:kernel][:shmall] = 2*1024*1024 #pages
default_unless[:sysctl][:kernel][:shmmax] = 32*1024*1024 #bytes
default_unless[:sysctl][:kernel][:shmmni] = 4096

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
