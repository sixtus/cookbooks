define :nagios_conf, variables: {}, subdir: true, action: :create, mode: "0644" do

  subdir = params[:subdir] ? "objects/" : ""
  params[:template] ||= "#{params[:name]}.cfg.erb"

  template "/etc/nagios/#{subdir}#{params[:name]}.cfg" do
    source params[:template]
    owner "nagios"
    group "nagios"
    mode params[:mode]
    variables params[:variables]
    notifies :restart, "service[nagios]"
    action params[:action]
    cookbook params[:cookbook] if params[:cookbook]
  end
end
