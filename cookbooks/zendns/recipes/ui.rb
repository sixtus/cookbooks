include_recipe "nodejs"

capistrano_skeleton "zendns"

monit_instance "zendns" do
  manage false
  action :delete if systemd_running?
end

nginx_unicorn "zendns" do
  homedir node[:zendns][:homedir]
  port node[:zendns][:port]
end

if node.chef_environment == "production"
  ssl_certificate "/etc/ssl/nginx/zendns" do
    cn node[:zendns][:ssl][:cn]
  end

  nginx_server "zendns" do
    template "nginx.conf"
  end
end
