include_recipe "php::base"

package "dev-php5/pecl-memcache"

php_extension "memcache" do
  template "memcache.ini.erb"
end
