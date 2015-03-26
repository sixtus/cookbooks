# remove old attributes
node.normal_attrs[:php].delete(:extension_dir)

portage_package_use "app-admin/eselect-php" do
  use %w(fpm)
  upgrade false
end

portage_package_use "dev-lang/php" do
  use node[:php][:default_use_flags] + node[:php][:use_flags] + node[:php][:sapi]
  upgrade false
end

portage_package_mask "dev-lang/php" do
  upgrade false
end

portage_package_mask "virtual/httpd-php" do
  upgrade false
end

portage_package_unmask "dev-lang/php:#{node[:php][:slot]}" do
  upgrade false
end

portage_package_unmask "=virtual/httpd-php-#{node[:php][:slot]}" do
  upgrade false
end

package "dev-lang/php" do
  version ":#{node[:php][:slot]}"
end

%w(
  /var/log/php-error.log
  /var/log/php-fpm.log
).each do |f|
  file f do
    action :delete
  end
end

file "/etc/logrotate.d/php" do
  action :delete
end

execute "eselect php set cli php#{node[:php][:slot]}" do
  not_if { %x(eselect php show cli).chomp == "php#{node[:php][:slot]}" }
end

execute "eselect php set fpm php#{node[:php][:slot]}" do
  not_if { %x(eselect php show fpm).chomp == "php#{node[:php][:slot]}" }
end

# reload attributes files to make the magic happen
node.load_attribute_by_short_filename('default', 'php') if node.respond_to?(:load_attribute_by_short_filename)

[
  node[:php][:tmp_dir],
  node[:php][:upload][:tmp_dir],
  node[:php][:session][:save_path],
].each do |p|
  directory p do
    owner "root"
    group "root"
    mode "1777"
  end
end

directory node[:php][:extension_dir] do
  owner "root"
  group "root"
  mode "0755"
  recursive true
end

template "/etc/php/cli-php#{node[:php][:slot]}/php.ini" do
  source "#{node[:php][:slot]}/php.ini"
  owner "root"
  group "root"
  mode "0644"
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

directory "/run/php-fpm" do
  owner "root"
  group "root"
  mode "0755"
end

systemd_unit "php-fpm.service" do
  template true
end

service "php-fpm" do
  action [:enable, :start]
end
