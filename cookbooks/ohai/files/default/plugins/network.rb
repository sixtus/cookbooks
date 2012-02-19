require 'resolv'
require 'open-uri'

provides "network"

network Mash.new unless network
network[:interfaces] = Mash.new unless network[:interfaces]

require_plugin "hostname"
require_plugin "#{os}::network"

# simply rely on the resolver, if that doesn't work you have a problem anyway.
default_addresses = network[:interfaces][network[:default_interface]][:addresses].keys

Resolv::DNS.open(:nameserver => ['8.8.8.8', '8.8.4.4']) do |dns|
  dns.getaddresses(fqdn).each do |r|
    next unless default_addresses.include?(r)
    if r.is_a?(Resolv::IPv4)
      ipaddress r.to_s
    elsif r.is_a?(Resolv::IPv6)
      ip6address r.to_s
    end
  end
end

unless ipaddress
  ipaddress open("http://ip.noova.de").read
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
