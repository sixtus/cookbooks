include_recipe "php::base"

package "dev-php/xcache"

php_extension "xcache" do
  template "xcache.ini.erb"
end
