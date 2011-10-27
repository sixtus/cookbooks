include_recipe "apache"

package "www-apache/mod_wsgi"

apache_module "70_mod_wsgi" do
  template "70_mod_wsgi.conf"
end
