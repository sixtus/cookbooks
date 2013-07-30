node.default[:php][:sapi] << "fpm" << "cgi"

include_recipe "php::base"

execute "eselect php set fpm php#{node[:php][:slot]}" do
  notifies :restart, "service[php-fpm]"
  not_if do
    %x(eselect php show fpm).chomp == "php#{node[:php][:slot]}"
  end
end

directory "/run/php-fpm" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/php/fpm-php#{node[:php][:slot]}/php.ini" do
  source "#{node[:php][:slot]}/php.ini"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[php-fpm]"
end

template "/etc/php/fpm-php#{node[:php][:slot]}/php-fpm.conf" do
  source "#{node[:php][:slot]}/php-fpm.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[php-fpm]"
end

systemd_tmpfiles "php-fpm"
systemd_unit "php-fpm.service"

service "php-fpm" do
  action [:enable, :start]
end
