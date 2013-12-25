define :nrpe_command, command: nil, action: :create do
  # this should already be handled in recipes,
  # but we do it here again for good measure
  next unless nagios_client?

  include_recipe "nagios::nrpe"

  file "/etc/nagios/nrpe.d/#{params[:name]}.cfg" do
    content "command[#{params[:name]}]=#{params[:command]}\n"
    owner "nagios"
    group "nagios"
    mode "0600"
    notifies :restart, "service[nrpe]"
    action params[:action]
  end
end
