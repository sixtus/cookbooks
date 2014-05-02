include_recipe "portage"

package "sys-apps/gentoo-functions"

link "/etc/init.d/functions.sh" do
  to "/lib/gentoo/functions.sh"
end

# stupid #$%^&*
link "/sbin/ip" do
  to "/bin/ip"
end
