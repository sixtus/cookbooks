package "app-emulation/virtualbox"
package "app-emulation/vagrant"

shorewall_interface "net" do
  interface "vboxnet0 0.0.0.0 optional"
end
