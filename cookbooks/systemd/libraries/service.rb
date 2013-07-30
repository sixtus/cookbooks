class Chef::Resource::Service
  SYSTEMD_UNIT_TYPES = %w(
    automount
    device
    mount
    path
    service
    snapshot
    socket
    swap
    target
    timer
  )

  def service_name(arg=nil)
    if systemd_running? and arg and not arg =~ /\.(#{SYSTEMD_UNIT_TYPES.join('|')})$/
      arg = "#{arg.gsub(/\./, '@')}.service"
    end

    arg = set_or_return(
      :service_name,
      arg,
      :kind_of => [ String ]
    )

    if systemd_running? and arg and not arg =~ /\.(#{SYSTEMD_UNIT_TYPES.join('|')})$/
      arg = "#{arg.gsub(/\./, '@')}.service"
    end

    arg
  end
end

class Chef::Provider::Service::Systemd
  def enable_service
    run_command_with_systems_locale(:command => "/bin/systemctl enable #{@new_resource.service_name}")
    @run_context.node.set[:systemd][:units][@new_resource.service_name] = true
  end

  def disable_service
    run_command_with_systems_locale(:command => "/bin/systemctl disable #{@new_resource.service_name}")
    @run_context.node.set[:systemd][:units][@new_resource.service_name] = false
  end
end

if systemd_running?
  Chef::Platform.set({
    :platform => :gentoo,
    :resource => :service,
    :provider => Chef::Provider::Service::Systemd
  })
end
