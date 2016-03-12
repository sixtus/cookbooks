directory "/etc/shorewall" do
  owner "root"
  group "root"
  mode "0700"
end

%w(
  shorewall.conf
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
    if gentoo? # shorewall 5.x
      source "ipv4/5.x/#{t}"
    else # shorewall 4.x
      source "ipv4/4.x/#{t}"
    end
    owner "root"
    group "root"
    mode "0600"
    notifies :restart, "service[shorewall]"
  end
end

if debian_based?
  file "/etc/default/shorewall" do
    content "startup=1\n"
    owner "root"
    group "root"
    mode "0644"
  end
end

systemd_unit "shorewall.service" do
  template true
end

service "shorewall" do
  action [:enable, :start]
end

if nagios_client?
  sudo_rule "nagios-shorewall" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /usr/sbin/shorewall status"
  end

  nagios_plugin "check_shorewall"

  nrpe_command "check_shorewall" do
    command "/usr/lib/nagios/plugins/check_shorewall"
  end

  nagios_service "SHOREWALL" do
    check_command "check_nrpe!check_shorewall"
    servicegroups "network"
    env [:testing, :development]
  end
end
