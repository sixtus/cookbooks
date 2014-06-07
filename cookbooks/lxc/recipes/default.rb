include_recipe "debootstrap"
include_recipe "dnsmasq"

#cookbook_file "/etc/dhcpcd.conf" do
#  source "dhcpcd.conf"
#  owner "root"
#  group "root"
#  mode "0640"
#end

cookbook_file "/etc/dnsmasq.d/lxc" do
  source "lxc.dnsmasq"
  owner "root"
  group "root"
  mode "0640"
end

systemd_unit "lxc-network.service"

service "lxc-network" do
  action [:enable, :start]
end

if gentoo?
  package "app-emulation/lxc"
  package "net-misc/bridge-utils"
elsif debian_based?
  package "lxc"
  package "bridge-utils"
end

directory "/usr/share/lxc" do
  owner "root"
  group "root"
  mode "0755"
end

directory "/usr/share/lxc/templates" do
  owner "root"
  group "root"
  mode "0755"
end

%w(gentoo ubuntu).each do |platform|
  cookbook_file "/usr/share/lxc/templates/lxc-#{platform}" do
    source "lxc-#{platform}"
    owner "root"
    group "root"
    mode "0755"
  end
end

systemd_unit "lxc@.service"
