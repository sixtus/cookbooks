template "/etc/pam.d/system-auth" do
  source "system-auth.pamd"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/nsswitch.conf" do
  source "nsswitch.conf"
  owner "root"
  group "root"
  mode "0644"
end

package "sys-apps/unscd"

service "unscd" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_nscd" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/nscd/nscd.pid /usr/sbin/unscd"
  end

  nagios_service "NSCD" do
    check_command "check_nrpe!check_nscd"
  end
end
