require 'socket'

provides "network"

network Mash.new unless network
network[:interfaces] = Mash.new unless network[:interfaces]

require_plugin "hostname"
require_plugin "#{os}::network"

# simply rely on the resolver, if that doesn't work you have a problem anyway.
Socket.getaddrinfo(fqdn, nil).each do |family, _, _, ip, _, _, _|
  case family
  when "AF_INET"
    ipaddress ip
  when "AF_INET6"
    ip6address ip
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
