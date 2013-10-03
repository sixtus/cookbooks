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
