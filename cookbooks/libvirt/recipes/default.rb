package "app-emulation/libvirt"

service "libvirtd" do
  action [:enable, :start]
end
