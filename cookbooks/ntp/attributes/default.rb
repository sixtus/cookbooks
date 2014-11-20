%x(whois #{node[:ipaddress]} | grep -q HETZNER-RZ)
if $?.exitstatus == 0
  default[:ntp][:server] = %w(
    ntp1.hetzner.de
    ntp2.hetzner.com
    ntp3.hetzner.net
  )
else
  default[:ntp][:server] = %w(
    0.pool.ntp.org
    1.pool.ntp.org
    2.pool.ntp.org
    3.pool.ntp.org
  )
end
