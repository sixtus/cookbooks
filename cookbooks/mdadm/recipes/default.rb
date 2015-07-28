if gentoo?
  package "sys-fs/mdadm"
elsif debian_based?
  package "mdadm"
else
  raise "cookbook mdadm does not support platform #{node[:platform]}"
end

service "mdmonitor" do
  if lxc?
    action [:disable, :stop]
  else
    action [:enable, :start]
  end
end

template "/etc/mdadm.conf" do
  source "mdadm.conf"
  owner "root"
  group "root"
  mode "0644"
end
