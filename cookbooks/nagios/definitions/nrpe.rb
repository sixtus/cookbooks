define :nrpe_command,
  :command => nil,
  :action => :create do

  include_recipe "nagios::nrpe"

  file "/etc/nagios/nrpe.d/#{params[:name]}.cfg" do
    content "command[#{params[:name]}]=#{params[:command]}\n"
    owner "nagios"
    group "nagios"
    mode "0600"
    notifies :restart, resources(:service => "nrpe")
    action params[:action]
  end
end
