define :nagios_plugin,
  :action => :create,
  :source => nil,
  :content => nil,
  :cookbook => nil do

  next if solo?
  next if platform?("mac_os_x")

  include_recipe "nagios::nrpe"

  directory "/usr/lib/nagios" do
    owner "root"
    group "root"
    mode "0755"
  end

  directory "/usr/lib/nagios/plugins" do
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

    cookbook_file "/usr/lib/nagios/plugins/#{params[:name]}" do
      source params[:source]
      cookbook params[:cookbook] if params[:cookbook]
      owner "root"
      group "nagios"
      mode "0750"
      action params[:action]
    end
  end
end
