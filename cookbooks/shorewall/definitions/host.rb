define :shorewall_host, options: "-" do
  node.set[:shorewall][:hosts][params[:name]] = params
end
