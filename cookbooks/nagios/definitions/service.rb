define :nagios_service do
  name = params.delete(:name)

  params[:service_description] = name
  params[:host_name] ||= node[:fqdn]

  node.default[:nagios][:services][name] = params
end

define :nagios_service_dependency do
  name = params.delete(:name)
  node.default[:nagios][:services][name][:dependencies] ||= []
  node.default[:nagios][:services][name][:dependencies] |= params[:depends]
end

define :nagios_service_escalation do
  name = params.delete(:name)
  node.default[:nagios][:services][name][:escalations] ||= []
  node.default[:nagios][:services][name][:escalations] |= [params]
end
