define :nagios_plugin, action: :create, source: nil, content: nil, cookbook: nil, template: nil do
  # this should already be handled in recipes,
  # but we do it here again for good measure
  next unless nagios_client?

  include_recipe "nagios::nrpe"

  directory "/usr/lib/nagios-#{rrand}" do
    path "/usr/lib/nagios"
    owner "root"
    group "root"
    mode "0755"
  end

  directory "/usr/lib/nagios/plugins-#{rrand}" do
    path "/usr/lib/nagios/plugins"
    owner "root"
    group "nagios"
    mode "0750"
  end

  if params[:content]
    file "/usr/lib/nagios/plugins/#{params[:name]}" do
      content params[:content]
      owner "root"
      group "nagios"
      mode "0750"
      action params[:action]
    end
  else
    unless params[:source]
      params[:source] = params[:name]
    end

    if params[:template]
      template "/usr/lib/nagios/plugins/#{params[:name]}-#{rrand}" do
        path "/usr/lib/nagios/plugins/#{params[:name]}"
        source params[:source]
        cookbook params[:cookbook] if params[:cookbook]
        owner "root"
        group "nagios"
        mode "0750"
        action params[:action]
      end
    else
      cookbook_file "/usr/lib/nagios/plugins/#{params[:name]}-#{rrand}" do
        path "/usr/lib/nagios/plugins/#{params[:name]}"
        source params[:source]
        cookbook params[:cookbook] if params[:cookbook]
        owner "root"
        group "nagios"
        mode "0750"
        action params[:action]
      end
    end
  end
end
