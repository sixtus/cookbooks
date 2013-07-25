include_recipe "nodejs"

capistrano_skeleton "zendns"

systemd_user_session "zendns"

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

  shorewall_rule "zendns-ui" do
    destport "http,https"
  end
end
