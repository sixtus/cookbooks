service "systemd-sysctl.service" do
  action [:enable, :start]
  only_if { systemd_running? }
end

execute "sysctl-reload" do
  command "/sbin/sysctl -p /etc/sysctl.conf"
  command "/usr/lib/systemd/systemd-sysctl" if systemd_running?
  action :nothing
end

link "/etc/sysctl.conf" do
  action :delete
  only_if { File.symlink?("/etc/sysctl.conf") }
end

template "/etc/sysctl.conf" do
  owner "root"
  group "root"
  mode "0644"
  source "sysctl.conf"
  notifies :run, "execute[sysctl-reload]"
end

directory "/etc/sysctl.d" do
  owner "root"
  group "root"
  mode "0755"
end

link "/etc/sysctl.d/99-sysctl.conf" do
  to "/etc/sysctl.conf"
end

file "/etc/sysctl.d/base.conf" do
  action :delete
end

template "/etc/security/limits.conf" do
  source "limits.conf"
  owner "root"
  group "root"
  mode "0644"
end

(node[:interrupts] || {}).each do |id, config|
  config.each do |key, value|
    file "/proc/irq/#{id}/#{key}" do
      content "#{value}\n"
    end
  end
end
