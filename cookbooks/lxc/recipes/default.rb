case node[:platform]
when "gentoo"
  package "app-emulation/lxc"
  package "net-misc/bridge-utils"

  cookbook_file "/usr/share/lxc/templates/lxc-gentoo" do
    source "lxc-gentoo"
    owner "root"
    group "root"
    mode "0755"
  end

when "debian"
  package "lxc"

  cookbook_file "/usr/lib/lxc/templates/lxc-gentoo" do
    source "lxc-gentoo"
    owner "root"
    group "root"
    mode "0755"
  end

end

systemd_unit "lxc@.service"
