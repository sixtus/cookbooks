case node[:platform]
when "gentoo"
  package "app-emulation/lxc"
  package "net-misc/bridge-utils"

when "debian"
  package "lxc"
end

systemd_unit "lxc@.service"
