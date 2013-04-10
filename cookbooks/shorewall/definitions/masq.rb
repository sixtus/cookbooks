define :shorewall_masq,
  :interface => nil,
  :source => nil do
  node.set[:shorewall][:masq][params[:name]] = params
end
