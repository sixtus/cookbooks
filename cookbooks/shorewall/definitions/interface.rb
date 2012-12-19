define :shorewall_interface,
  :interface => nil do
  node.set[:shorewall][:interfaces][params[:name]] = params[:interface]
end
