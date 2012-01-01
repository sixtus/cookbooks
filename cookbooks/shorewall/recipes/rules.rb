# use this recipe to define resources for shorewall rules

nodes = Hash[node.run_state[:nodes].map do |n|
  [n[:fqdn], n[:ipaddress]]
end]

nodes6 = Hash[node.run_state[:nodes].select do |n|
  n[:ip6address]
end.map do |n|
  [n[:fqdn], n[:ip6address]]
end]

case node[:fqdn]

when "host.example.com"

  # for virtual servers use dest with nodes hash
  shorewall_rule "nginx@my" do
    dest "$FW:#{nodes['my.example.com']}"
    destport "http,https"
  end

when "lb.example.com"

  # for bare metal dest can be ommited
  shorewall_rule "nginx" do
    destport "http,https"
  end

end
