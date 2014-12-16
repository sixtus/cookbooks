include_recipe "portage"

package "sys-apps/gentoo-functions"

# need this until every script is updated
directory "/etc/init.d"

link "/etc/init.d/functions.sh" do
  to "/lib/gentoo/functions.sh"
end

# stupid #$%^&*
link "/sbin/ip" do
  to "/bin/ip"
end

package "sys-apps/irqd"

directory "/var/lib/misc"

systemd_unit "irqd.service"

service "irqd" do
  action [:enable, :start]
end

file "/etc/resolvconf.conf" do
  content "resolv_conf=/tmp/.resolv.conf\n"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/etc/dhcpcd.conf" do
  source "dhcpcd.conf"
  owner "root"
  group "root"
  mode "0640"
  #notifies :restart, "service[dhcpcd]"
end

service "dhcpcd" do
  action [:enable, :start]
  only_if { File.exist?("/etc/systemd/system/multi-user.target.wants/dhcpcd.service") }
end
