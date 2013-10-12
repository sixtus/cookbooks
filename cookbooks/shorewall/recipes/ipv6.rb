if gentoo?
  package "net-firewall/shorewall6"

elsif debian_based?
  package "shorewall6"
end

execute "shorewall6-restart" do
  command "/sbin/shorewall6 -q restart"
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

systemd_unit "shorewall6.service" do
  template "shorewall6.service"
end

service "shorewall6" do
  action [:enable, :start]
end

splunk_input "monitor:///var/log/shorewall6-init.log"

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
    env [:testing, :development]
  end
end
