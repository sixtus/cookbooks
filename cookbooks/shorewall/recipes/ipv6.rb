package "net-firewall/shorewall6"

execute "shorewall6-restart" do
  command "/sbin/shorewall6 restart"
  action :nothing
end

directory "/etc/shorewall6" do
  owner "root"
  group "root"
  mode "0700"
end

template "/etc/shorewall6/shorewall6.conf" do
  source "ipv6/shorewall6.conf"
  owner "root"
  group "root"
  mode "0600"
  notifies :run, "execute[shorewall6-restart]"
end

%w(
  hosts
  interfaces
  policy
  rules
  tunnels
  zones
).each do |t|
  template "/etc/shorewall6/#{t}" do
    source "ipv6/#{t}"
    owner "root"
    group "root"
    mode "0600"
    notifies :run, "execute[shorewall6-restart]"
  end
end

directory "/var/lock/subsys"

service "shorewall6" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  sudo_rule "nagios-shorewall6" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /sbin/shorewall6 status"
  end

  nagios_plugin "check_shorewall6"

  nrpe_command "check_shorewall6" do
    command "/usr/lib/nagios/plugins/check_shorewall6"
  end

  nagios_service "SHOREWALL6" do
    check_command "check_nrpe!check_shorewall6"
    servicegroups "system"
  end
end
