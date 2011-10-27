portage_package_use "dev-lang/php" do
  use node[:php][:default_use_flags] + node[:php][:use_flags] + node[:php][:sapi]
end

package "dev-lang/php"

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

template "/etc/php/cli-php#{PHP.slot}/php.ini" do
  source "#{PHP.slot}/php.ini"
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
