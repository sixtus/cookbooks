if gentoo?
  package "sys-fs/mdadm"

elsif debian_based?
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
