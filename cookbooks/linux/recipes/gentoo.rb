# stupid #$%^&*
link "/sbin/ip" do
  to "/bin/ip"
end

link "/bin/systemctl" do
  to "/usr/bin/systemctl"
end

include_recipe "portage"

package "sys-apps/gentoo-functions"

# need this until every script is updated
directory "/etc/init.d"

link "/etc/init.d/functions.sh" do
  to "/lib/gentoo/functions.sh"
end

directory "/var/lib/misc"

package "sys-apps/irqbalance"
package "sys-apps/irqd"

if node[:cpu][:total] > 32
  service "irqd" do
    action [:disable, :stop]
  end

  service "irqbalance" do
    action [:enable, :start]
  end
else
  systemd_unit "irqd.service"

  service "irqbalance" do
    action [:disable, :stop]
  end

  service "irqd" do
    action [:enable, :start]
  end
end

file "/etc/resolvconf.conf" do
  content "resolv_conf=/tmp/.resolv.conf\n"
  owner "root"
  group "root"
  mode "0644"
end

file "/etc/dhcpcd.conf" do
  action :delete
end
