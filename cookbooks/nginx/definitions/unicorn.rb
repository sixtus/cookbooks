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
end
