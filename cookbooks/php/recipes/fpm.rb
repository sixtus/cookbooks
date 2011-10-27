node.default[:php][:sapi] << "fpm" << "cgi"

include_recipe "php::base"

execute "eselect php set fpm php#{PHP.slot}" do
  notifies :restart, "service[php-fpm]"
  not_if do
    %x(eselect php show fpm).chomp == "php#{PHP.slot}"
  end
end

directory "/var/run/php-fpm" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/php/fpm-php#{PHP.slot}/php.ini" do
  source "#{PHP.slot}/php.ini"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[php-fpm]"
end

template "/etc/php/fpm-php#{PHP.slot}/php-fpm.conf" do
  source "#{PHP.slot}/php-fpm.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[php-fpm]"
end

service "php-fpm" do
  action [:enable, :start]
end

nrpe_command "check_php_fpm" do
  command "/usr/lib/nagios/plugins/check_pidfile /var/run/php-fpm.pid php-fpm"
end

nagios_service "PHP-FPM" do
  check_command "check_nrpe!check_php_fpm"
end
