# remove old attributes
node.normal_attrs[:php].delete(:extension_dir)

portage_package_use "app-admin/eselect-php" do
  use %w(fpm)
end

portage_package_use "dev-lang/php" do
  use node[:php][:default_use_flags] + node[:php][:use_flags] + node[:php][:sapi]
end

package "dev-lang/php" do
  action :upgrade
end

execute "eselect php set cli php#{node[:php][:slot]}" do
  user "root"
  group "root"
  not_if { %x(eselect php show cli).chomp == "php#{node[:php][:slot]}" }
end

# reload attributes files to make the magic happen
node.load_attribute_by_short_filename('default', 'php') if node.respond_to?(:load_attribute_by_short_filename)

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

template "/etc/php/cli-php#{node[:php][:slot]}/php.ini" do
  source "#{node[:php][:slot]}/php.ini"
  owner "root"
  group "root"
  mode "0644"
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

systemd_unit "php-fpm.service" do
  template true
end

service "php-fpm" do
  action [:enable, :start]
end
