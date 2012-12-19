define :shorewall_rule,
  :action => "ACCEPT",
  :source => "net",
  :dest => "$FW",
  :proto => "tcp",
  :destport => "-",
  :sourceport => "-" do
  node.set[:shorewall][:rules][params[:name]] = params
end

define :shorewall6_rule,
  :action => "ACCEPT",
  :source => "net",
  :dest => "$FW",
  :proto => "tcp",
  :destport => "-",
  :sourceport => "-" do
  node.set[:shorewall6][:rules][params[:name]] = params
end
