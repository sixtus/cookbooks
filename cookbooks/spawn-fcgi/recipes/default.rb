package "www-servers/spawn-fcgi"
package "www-misc/fcgiwrap"

file "/etc/conf.d/spawn-fcgi" do
  action :delete
end

systemd_tmpfiles "spawn-fcgi"
systemd_unit "spawn-fcgi@.service"
