if systemd_running?
  service "systemd-sysctl.service" do
    action [:enable, :start]
    only_if { systemd_running? }
  end

  template "/etc/sysctl.d/base.conf" do
    owner "root"
    group "root"
    mode "0644"
    source "sysctl.conf"
    notifies :restart, "service[systemd-sysctl.service]"
  end
else
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
    notifies :run, "execute[sysctl-reload]" unless systemd_running?
  end
end
