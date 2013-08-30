define :nagios_virtual_host do
  node.default[:nagios][:vhosts] ||= []
  node.default[:nagios][:vhosts] << params
end
