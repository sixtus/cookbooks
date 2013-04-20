# remove old cruft
%w(common perl shell).each do |p|
  package "net-firewall/shorewall-#{p}" do
    action :remove
  end
end

package "net-firewall/shorewall"

execute "shorewall-restart" do
  command "/sbin/shorewall -q restart"
  action :nothing
end

directory "/etc/shorewall" do
  owner "root"
  group "root"
  mode "0700"
end

template "/etc/shorewall/shorewall.conf" do
  source "ipv4/shorewall.conf"
  owner "root"
  group "root"
  mode "0600"
  notifies :run, "execute[shorewall-restart]"
end

%w(
  accounting
  hosts
  interfaces
  masq
  policy
  rules
  tunnels
  zones
).each do |t|
  template "/etc/shorewall/#{t}" do
    source "ipv4/#{t}"
    owner "root"
    group "root"
    mode "0600"
    notifies :run, "execute[shorewall-restart]"
  end
end

systemd_unit "shorewall.service"

service "shorewall" do
  if node[:virtualization][:role] == "guest"
    action [:disable]
  else
    action [:enable, :start]
  end
end

splunk_input "monitor:///var/log/shorewall-init.log"

if tagged?("nagios-client")
  sudo_rule "nagios-shorewall" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /sbin/shorewall status"
  end

  nagios_plugin "check_shorewall"

  nrpe_command "check_shorewall" do
    command "/usr/lib/nagios/plugins/check_shorewall"
  end

  nagios_service "SHOREWALL" do
    check_command "check_nrpe!check_shorewall"
    servicegroups "system"
    env [:testing, :development]
  end
end
