# no inception
if !vbox_guest?
  case node[:platform]
  when "gentoo"
    package "app-emulation/virtualbox"
    package "app-emulation/virtualbox-modules"
    package "app-emulation/vagrant"

    if root?
      file "/etc/modules-load.d/virtualbox.conf" do
        content "vboxnetflt\nvboxnetadp\nvboxpci\nvboxdrv\n"
        owner "root"
        group "root"
        mode "0644"
        notifies :restart, 'service[systemd-modules-load.service]'
      end

      shorewall_interface "net" do
        interface "vboxnet0 0.0.0.0 optional"
      end
    end

  when "mac_os_x"
    mac_package "VirtualBox" do
      source "http://download.virtualbox.org/virtualbox/4.2.18/VirtualBox-4.2.18-88780-OSX.dmg"
      type "pkg"
    end

    mac_package "Vagrant" do
      source "http://files.vagrantup.com/packages/7ec0ee1d00a916f80b109a298bab08e391945243/Vagrant-1.2.7.dmg"
      type "pkg"
    end
  end
end
