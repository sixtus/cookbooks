require 'ipaddr'

def rfc1918?(adr)
  [ IPAddr.new("10.0.0.0/8"),
    IPAddr.new("172.16.0.0/12"),
    IPAddr.new("192.168.0.0/16"),
    IPAddr.new("fc00::/7"),
  ].each do |net|
    return true if net.include?(adr)
  end
  return false
end

provides "network"

ipv6_enabled File.read("/proc/net/protocols").match(/TCPv6/)

# collect all known interfaces and addresses
iface = Mash.new

popen4("ip addr list") do |pid, stdin, stdout, stderr|
  stdin.close
  cint = nil
  seen = nil

  stdout.each do |line|
    if line =~ /^[0-9]+:\s+([0-9a-zA-Z]+):\s+<(.+)> mtu (\d+)/
      cint = $1
      seen = {
        :primary4 => false,
        :primary6 => false,
        :local4 => false,
        :local6 => false,
      }
      iface[cint] = Mash.new
      iface[cint][:addresses] = Mash.new
      iface[cint][:flags] = $2.split(',')
      iface[cint][:mtu] = $3
    end

    if line =~ /link\/(.+?)\s/
      iface[cint][:encapsulation] = $1
    end

    if line =~ /link\/ether (.+?) brd/
      iface[cint][:addresses][$1] = {
        "family" => "link"
      }
    end

    if line =~ /inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})(\/(\d+))?/
      adr, prefix = $1, $3
      prefix ||= "32"

      if rfc1918?(adr)
        primary = !seen[:local4]
        seen[:local4] = true
      else
        primary = !seen[:primary4]
        seen[:primary4] = true
      end

      iface[cint][:addresses][adr] = {
        "family" => "inet",
        "prefixlen" => prefix,
        "scope" => "global",
        "primary" => primary,
        "private" => rfc1918?(adr),
      }
      prim4 = false
    end

    if line =~ /inet6 ([a-f0-9\:]+)\/(\d+) scope (\w+)/
      adr, prefix, scope = $1, $2, $3

      if rfc1918?(adr)
        primary = !seen[:local6]
        seen[:local6] = true
      else
        primary = !seen[:primary6]
        seen[:primary6] = true
      end

      iface[cint][:addresses][adr] = {
        "family" => "inet6",
        "prefixlen" => prefix,
        "scope" => scope,
        "primary" => prim6,
        "private" => rfc1918?(adr),
      }
      prim6 = false
    end

    if line =~ /P-t-P:(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
      iface[cint][:peer] = $1
    end
  end
end

network[:interfaces] = iface

# figure out the default route/interface
route_result = from("ip route list \| grep -m 1 ^default").split(/[ \t]+/)
network[:default_gateway], network[:default_interface] = route_result.values_at(2,4)
