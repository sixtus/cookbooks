include_recipe "apache::fastcgi"

file "/etc/apache2/modules.d/70_mod_php5.conf" do
  action :delete
end

php_fpm_pool "apache" do
  user "apache"
  group "apache"
  listen ({
    :owner => "apache",
    :group => "apache",
    :mode => "0660",
  })
  pm ({
    :type => "static",
    :max_children => node[:apache][:php][:max_children],
  })
end

apache_module "70_php_fpm" do
  template "70_php_fpm.conf"
end
