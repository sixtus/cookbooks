execute "sysctl-reload" do
  command "/sbin/sysctl -p /etc/sysctl.conf"
  action :nothing
  not_if do
    node[:virtualization][:system] == "linux-vserver" and
    node[:virtualization][:role] == "guest"
  end
end

template "/etc/sysctl.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "sysctl.conf"
  notifies :run, "execute[sysctl-reload]"
end
