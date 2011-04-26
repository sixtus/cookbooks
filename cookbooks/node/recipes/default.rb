begin
  include_recipe "node::#{node[:fqdn]}"
rescue ArgumentError
  # do nothing if node-specific recipe does not exist
end
