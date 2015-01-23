directory "/srv/system/etc/apache" do
  owner "root"
  group "root"
  mode "0755"
end

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

cookbook_file "#{node[:php][:extension_dir]}/ioncube_loader_lin_#{node[:php][:slot]}.so" do
  source "web/ioncube_loader_lin_#{node[:php][:slot]}.so"
end

php_extension "ioncube" do
  template "web/ioncube.ini"
end

cookbook_file "#{node[:php][:extension_dir]}/ixed.#{node[:php][:slot]}.lin" do
  source "web/ixed.#{node[:php][:slot]}.lin"
end

php_extension "sourceguardian" do
  template "web/sourceguardian.ini"
end

if %w(5.3 5.4).include?(node[:php][:slot])
  cookbook_file "#{node[:php][:extension_dir]}/ZendGuardLoader-#{node[:php][:slot]}.so" do
    source "web/ZendGuardLoader-#{node[:php][:slot]}.so"
  end

  php_extension "zendguard" do
    template "web/zendguard.ini"
  end
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
