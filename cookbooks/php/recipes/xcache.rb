include_recipe "php"

package "dev-php/xcache"

php_extension "xcache" do
  template "xcache.ini.erb"
end
