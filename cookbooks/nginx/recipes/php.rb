include_recipe "nginx"

php_fpm_pool "nginx" do
  user "nginx"
  group "nginx"
  listen ({
    :owner => "nginx",
    :group => "nginx",
    :mode => "0660",
  })
  pm ({
    :type => "static",
    :max_children => node[:nginx][:php][:max_children],
  })
end

nginx_module "php" do
  template "php.conf"
  auto false
end

link "/etc/nginx/php.conf" do
  to "/etc/nginx/modules/php.include"
end
