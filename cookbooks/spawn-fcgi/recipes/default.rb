package "www-servers/spawn-fcgi"
package "www-misc/fcgiwrap"

directory "/var/run/spawn-fcgi" do
  owner "root"
  group "root"
  mode "0755"
end

file "/etc/conf.d/spawn-fcgi" do
  action :delete
end

systemd_tmpfiles "spawn-fcgi"
systemd_unit "spawn-fcgi@.service"
