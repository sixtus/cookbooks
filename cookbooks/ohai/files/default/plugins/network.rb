provides "network"

network Mash.new unless network
network[:interfaces] = Mash.new unless network[:interfaces]

require_plugin "hostname"
require_plugin "#{os}::network"

network[:interfaces][network[:default_interface]][:addresses].each do |adr, net|
  next unless net[:family] =~ /^inet/
  next if rfc1918?(adr)

  if net[:family] == "inet" and net[:primary]
    ipaddress adr
    ipprefixlen net[:prefixlen]
  end

  if net[:family] == "inet6" and net[:scope] != "link" and net[:primary]
    ip6address adr
    ip6prefixlen net[:prefixlen]
  end

  if net[:family] == "link"
    macaddress adr
  end
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
