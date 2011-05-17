include_recipe "apache"

package "www-apache/passenger"

apache_module "30_mod_passenger" do
  template "30_mod_passenger.conf"
end
