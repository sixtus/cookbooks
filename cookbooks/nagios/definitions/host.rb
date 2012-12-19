define :nagios_virtual_host do
  fqdn = params[:name]

  node.set[:nagios][:services] ||= {}
  services = node[:nagios][:services].select do |service_description, params|
    params[:host_name] == fqdn
  end

  host = {
    :fqdn => fqdn,
    :virtualization => {
      :host => nil,
    },
    :nagios => {
      :contact_groups => nil,
      :services => services
    },
  }

  nagios_conf "host-#{params[:name]}" do
    template "host.cfg.erb"
    cookbook "nagios"
    variables :host => host
  end
end
