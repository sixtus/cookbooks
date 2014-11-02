include_recipe "portage"

package "sys-apps/gentoo-functions"

link "/etc/init.d/functions.sh" do
  to "/lib/gentoo/functions.sh"
end

directory "/etc/local.d" do
  owner "root"
  group "root"
  mode "0755"
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
