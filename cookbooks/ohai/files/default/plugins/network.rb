provides "network"

network Mash.new unless network
network[:interfaces] = Mash.new unless network[:interfaces]

require_plugin "hostname"
require_plugin "#{os}::network"

default_ipaddress = network[:interfaces][network[:default_interface]][:addresses].select do |addr, opts|
  opts[:family] == "inet" and opts[:primary]
end.first

if default_ipaddress
  ipaddress default_ipaddress.first
end

default_ip6address = network[:interfaces][network[:default_interface]][:addresses].select do |addr, opts|
  opts[:family] == "inet6" and opts[:scope] != "link" and opts[:primary]
end.first

if default_ip6address
  ip6address default_ip6address.first
end

# try to figure out the private IP address if it exists
network[:interfaces].each do |int, cfg|
  cfg[:addresses].each do |adr, net|
    next unless net[:family] =~ /^inet/
    next unless rfc1918?(adr)

    local_interface int

    if net[:family] == "inet6" and net[:primary]
      local_ip6address adr
    end

    if net[:family] == "inet" and net[:primary]
      local_ipaddress adr
    end
  end
  break if local_interface
end
