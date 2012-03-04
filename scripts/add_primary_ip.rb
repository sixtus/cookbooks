nodes.all do |n|
  n.default_attrs[:primary_ipaddress] = n[:ipaddress]
  n.save
end
