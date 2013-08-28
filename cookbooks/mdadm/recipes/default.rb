case node[:platform]
when "gentoo"
  package "sys-fs/mdadm"

when "debian"
  package "mdadm"
end

service "mdadm" do
  action [:disable, :stop]
end

template "/etc/mdadm.conf" do
  source "mdadm.conf"
  owner "root"
  group "root"
  mode "0644"
end
