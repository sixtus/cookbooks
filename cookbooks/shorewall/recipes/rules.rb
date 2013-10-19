# use this recipe to define resources for shorewall rules

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
