directory "/etc/shorewall6" do
  owner "root"
  group "root"
  mode "0700"
end

%w(
  shorewall6.conf
  hosts
  interfaces
  policy
  rules
  tunnels
  zones
).each do |t|
  template "/etc/shorewall6/#{t}" do
    if gentoo? # shorewall 5.x
      source "ipv6/5.x/#{t}"
    else # shorewall 4.x
      source "ipv6/4.x/#{t}"
    end
    owner "root"
    group "root"
    mode "0600"
    notifies :restart, "service[shorewall6]"
  end
end

systemd_unit "shorewall6.service" do
  template "shorewall6.service"
end

service "shorewall6" do
  action [:enable, :start]
end

if nagios_client?
  sudo_rule "nagios-shorewall6" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /usr/sbin/shorewall6 status"
  end

  nagios_plugin "check_shorewall6"

  nrpe_command "check_shorewall6" do
    command "/usr/lib/nagios/plugins/check_shorewall6"
  end

  nagios_service "SHOREWALL6" do
    check_command "check_nrpe!check_shorewall6"
    servicegroups "network"
    env [:testing, :development]
  end
end
