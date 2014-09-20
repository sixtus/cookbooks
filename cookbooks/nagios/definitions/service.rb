class ::Chef::Recipe
  def nagios_service_defaults(params)
    name = params.delete(:name)
    params[:service_description] ||= name
    params[:host_name] ||= node[:fqdn]
    params[:env] ||= []
    params[:env] |= [:production]
    return [name, params]
  end
end

define :nagios_service do
  name, p = nagios_service_defaults(params)
  node.default[:nagios][:services][name] = p
end

define :nagios_cluster_service do
  name, p = nagios_service_defaults(params)
  p[:host_name] = node.cluster_domain
  node.default[:nagios][:services][name] = p
end

define :nagios_service_dependency do
  name = params.delete(:name)
  node.default[:nagios][:services][name][:dependencies] = node.default[:nagios][:services][name][:dependencies].to_a | params[:depends]
end
