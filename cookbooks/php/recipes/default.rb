portage_package_use "dev-lang/php" do
  use node[:php][:default_use_flags] + node[:php][:use_flags] + %w(cgi fpm)
end

package "dev-lang/php"

execute "eselect php set fpm php#{PHP.slot}" do
  notifies :restart, "service[php-fpm]"
  not_if do
    %x(eselect php show fpm).chomp == "php#{PHP.slot}"
  end
end

ruby_block "php-extension-dir" do
  block do
    node.set[:php][:extension_dir] = %x(/usr/lib/php#{PHP.slot}/bin/php-config --extension-dir).strip
  end
end

[
  node[:php][:tmp_dir],
  node[:php][:upload][:tmp_dir],
  node[:php][:session][:save_path]
].each do |p|
  directory p do
    owner "root"
    group "root"
    mode "1777"
  end
end

directory "/var/run/php-fpm" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/php/cli-php#{PHP.slot}/php.ini" do
  source "#{PHP.slot}/php.ini"
  owner "root"
  group "root"
  mode "0644"
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

include_recipe "php::xcache"

%w(
  /var/log/php-error.log
  /etc/syslog-ng/conf.d/90-php.conf
).each do |f|
  file f do
    action :delete
  end
end

cookbook_file "/etc/logrotate.d/php" do
  source "logrotate.conf"
  owner "root"
  group "root"
  mode "0644"
end

nrpe_command "check_php_fpm" do
  command "/usr/lib/nagios/plugins/check_pidfile /var/run/php-fpm.pid php-fpm"
end

nagios_service "PHP-FPM" do
  check_command "check_nrpe!check_php_fpm"
end
