include_recipe "apache"

file "/etc/apache2/modules.d/70_php_fpm.conf" do
  action :delete
end

node.default[:php][:sapi] << "apache2"

include_recipe "php::base"

template "/etc/php/apache2-php#{PHP.slot}/php.ini" do
  source "#{PHP.slot}/php.ini"
  cookbook "php"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, "service[apache2]"
end

apache_module "70_mod_php5" do
  template "70_mod_php5.conf"
end
