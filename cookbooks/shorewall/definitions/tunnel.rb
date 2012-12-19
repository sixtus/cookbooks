define :shorewall_tunnel,
  :vpntype => "openvpn",
  :zone => nil,
  :gateway => nil do
  node.set[:shorewall][:tunnels][params[:name]] = params
end
