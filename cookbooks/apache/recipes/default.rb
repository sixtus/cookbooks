portage_package_use "dev-libs/apr-util" do
  use node[:apache][:apr_util][:use]
end

portage_package_use "www-servers/apache" do
  use([
    "-*", "ssl", "static",
    "apache2_mpms_#{node[:apache][:mpm]}",
    node[:apache][:modules].map { |m| "apache2_modules_#{m}" }
  ].flatten.sort.join(" "))
end

package "www-servers/apache"

ssl_ca "/etc/ssl/apache2/ca" do
  notifies :restart, "service[apache2]"
end

ssl_certificate "/etc/ssl/apache2/server" do
  cn node[:fqdn]
  notifies :restart, "service[apache2]"
end

template "/etc/apache2/httpd.conf" do
  source "httpd.conf"
  mode "0644"
  owner "root"
  group "root"
  notifies :restart, "service[apache2]"
end

%w(common_redirect log_rotate extract_forwarded).each do |pkg|
  package "www-apache/mod_#{pkg}"
end

%w(
  00_default_vhost.conf
  00_default_ssl_vhost.conf
  default_vhost.include
).each do |conf|
  file "/etc/apache2/vhosts.d/#{conf}" do
    action :delete
    notifies :restart, "service[apache2]"
  end
end

# old cruft, filename is actually 20_mod_fastcgi_handler.conf
file "/etc/apache2/modules.d/10_mod_fastcgi_handler.conf" do
  action :delete
  notifies :restart, "service[apache2]"
end

%w(
  00_default_settings
  00_error_documents
  00_languages
  00_mod_autoindex
  00_mod_info
  00_mod_log_config
  00_mod_mime
  00_mod_status
  00_mod_userdir
  00_mpm
  10_mod_log_rotate
  10_mod_mem_cache
  20_mod_common_redirect
  40_mod_ssl
  46_mod_ldap
  98_mod_extract_forwarded
).each do |m|
  apache_module m do
    template "#{m}.conf"
  end
end

apache_vhost "status" do
  template "status.conf"
end

if node[:apache][:default_vhost]
  default_action = :create
else
  default_action = :delete
end

apache_vhost "00-default" do
  template "default.conf"
  action default_action
end

systemd_unit "apache2.service"

service "apache2" do
  action [:start, :enable]
  supports [:reload]
end

cookbook_file "/etc/logrotate.d/apache2" do
  source "logrotate.conf"
  owner "root"
  group "root"
  mode "0644"
end

# errors go to syslog, no need to confuse everybody with empty error_logs
file "/var/log/apache2/error_log" do
  action :delete
  backup 0
end

# nagios service checks
if nagios_client?
  package "dev-perl/libwww-perl"

  nagios_plugin "check_apache2"

  nrpe_command "check_apache2" do
    command "/usr/lib/nagios/plugins/check_apache2 -H localhost -p 8030 -u / -w 20 -c 3"
  end

  nagios_service "APACHE2" do
    check_command "check_nrpe!check_apache2"
  end
end
