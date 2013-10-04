case node[:platform]
when "gentoo"
  package "app-emulation/lxc"
  package "net-misc/bridge-utils"

when "debian"
  package "lxc"

end

cookbook_file "/usr/share/lxc/templates/lxc-gentoo" do
  source "lxc-gentoo"
  owner "root"
  group "root"
  mode "0755"
end

systemd_unit "lxc@.service"
