define :nrpe_command do
  node.set[:nagios][:nrpe][:commands][params[:name]] = params[:command]
end
