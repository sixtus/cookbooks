package "app-emulation/libvirt"

cookbook_file "/etc/libvirt/libvirt.conf" do
  source "libvirt.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[libvirtd]"
end

service "libvirtd" do
  action [:enable, :start]
end
