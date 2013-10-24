include_recipe "nginx"

nginx_module "fastcgi" do
  template "fastcgi.conf"
end

link "/etc/nginx/fastcgi.conf" do
  to "/etc/nginx/modules/fastcgi.conf"
end

link "/etc/nginx/fastcgi_params" do
  to "/etc/nginx/modules/fastcgi.conf"
end
