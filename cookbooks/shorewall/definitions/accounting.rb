define :shorewall_accounting, target: "misc", address: "-", proto: "-", port: "-" do
  node.set[:shorewall][:accounting][params[:name]] = params
end
