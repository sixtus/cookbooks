# configure and update sysctl/init
if node[:virtualization][:role] == "guest" and node[:virtualization][:system] == "linux-vserver"
  execute "sysctl-reload" do
    command "/bin/true"
    action :nothing
  end
else
  execute "sysctl-reload" do
    command "/sbin/sysctl -p /etc/sysctl.conf"
    action :nothing
  end
end

template "/etc/sysctl.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "sysctl.conf"
  notifies :run, "execute[sysctl-reload]"
end
