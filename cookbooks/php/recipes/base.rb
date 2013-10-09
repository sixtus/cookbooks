# remove old attributes
node.normal_attrs[:php].delete(:extension_dir)

portage_package_use "app-admin/eselect-php" do
  use %w(fpm)
end

portage_package_use "dev-lang/php" do
  use node[:php][:default_use_flags] + node[:php][:use_flags] + node[:php][:sapi]
end

portage_package_use "dev-php/xcache" do
  use ["php_targets_php#{node[:php][:slot].sub(/\./, '-')}"]
end

# we pull dev-lang/php implicitly via xcache so that we can guarantee the
# correct slot with the above package.use resource
package "dev-php/xcache"

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

php_extension "xcache"

%w(
  /var/log/php-error.log
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
