define :nginx_unicorn do
  name = params[:name]
  homedir = params[:homedir]
  port = params[:port]

  file "/etc/nginx/servers/capistrano_unicorn-#{name}.conf" do
    action :delete
  end

  nginx_server "unicorn-#{name}" do
    template "unicorn.nginx.conf"
    cookbook "nginx"
    user name
    homedir homedir
    port port
  end

  if tagged?("nagios-client")
    nrpe_command "check_#{name}_unicorn" do
      command "/usr/lib/nagios/plugins/check_pidfile #{homedir}/shared/pids/unicorn.pid"
    end

    nagios_service "#{name.upcase}-UNICORN" do
      check_command "check_nrpe!check_#{name}_unicorn"
      servicegroups name
    end
  end
end
