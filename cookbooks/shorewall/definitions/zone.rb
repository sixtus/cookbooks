define :shorewall_zone,
  :type => "ipv4" do
  node.set[:shorewall][:zones][params[:name]] = params[:type]
end
