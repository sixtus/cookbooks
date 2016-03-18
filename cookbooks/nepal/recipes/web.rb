# PHP

directory "/srv/system/etc/php" do
  owner "root"
  group "root"
  mode "0755"
end

template "/srv/system/etc/php/fpm.conf" do
  source "web/fpm.conf"
  owner "root"
  group "root"
  mode "0644"
  not_if { File.exist?("/srv/system/etc/php/fpm.conf") }
end

node.default[:php][:fpm][:conf] = "/srv/system/etc/php/fpm.conf"
include_recipe "php"

cookbook_file "#{node.php_extension_dir}/ioncube_loader_lin_#{node[:php][:slot]}.so" do
  source "web/ioncube_loader_lin_#{node[:php][:slot]}.so"
end

php_extension "ioncube" do
  template "web/ioncube.ini"
end

cookbook_file "#{node.php_extension_dir}/ixed.#{node[:php][:slot]}.lin" do
  source "web/ixed.#{node[:php][:slot]}.lin"
end

php_extension "sourceguardian" do
  template "web/sourceguardian.ini"
end

if %w(5.3 5.4).include?(node[:php][:slot])
  cookbook_file "#{node.php_extension_dir}/ZendGuardLoader-#{node[:php][:slot]}.so" do
    source "web/ZendGuardLoader-#{node[:php][:slot]}.so"
  end

  php_extension "zendguard" do
    template "web/zendguard.ini"
  end
end

package "dev-php/xcache"

php_extension "xcache" do
  template "web/xcache.ini"
end

package "dev-php/xdebug"

directory "/var/tmp/php/xdebug" do
  owner "root"
  group "root"
  mode "1777"
end

php_extension "xdebug" do
  template "web/xdebug.ini"
  sapi %w(fpm)
end

# Apache

directory "/srv/system/etc/apache" do
  owner "root"
  group "root"
  mode "0755"
end

include_recipe "apache::fastcgi"
include_recipe "apache::wsgi"

file "/etc/apache2/modules.d/70_php_fpm.conf" do
  action :delete
  notifies :reload, "service[apache2]"
end

package "www-apache/mod_security"

apache_module "79_modsecurity" do
  template "web/79_mod_security.conf"
end

package "www-apache/mod_pagespeed"

htpasswd_from_users "/etc/apache2/modules.d/80_mod_pagespeed.passwd" do
  query ->(user) { user[:tags] && user[:tags].include?("hostmaster") }
  owner "apache"
end

apache_module "80_mod_pagespeed" do
  template "web/80_mod_pagespeed.conf"
end

ssl_certificate "/srv/system/etc/apache/server" do
  cn node[:fqdn]
end

execute "/usr/bin/nepalc generate_apache_conf" do
  creates "/srv/system/etc/apache/listen.conf"
end

apache_vhost "nepal" do
  template "web/apache.conf"
end

shorewall_rule "web" do
  destport "80,443"
end

shorewall6_rule "web" do
  destport "80,443"
end
