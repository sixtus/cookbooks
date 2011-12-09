# remove old attributes
node.normal_attrs[:php].delete(:extension_dir)

portage_package_use "dev-lang/php" do
  use node[:php][:default_use_flags] + node[:php][:use_flags] + node[:php][:sapi]
end

package "dev-lang/php"

# reload attributes files to make the magic happen
node.load_attribute_by_short_filename('default', 'php')

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
