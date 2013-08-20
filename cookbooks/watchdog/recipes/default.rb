package "sys-apps/watchdog"

cookbook_file "/etc/watchdog.conf" do
  source "watchdog.conf"
  owner "root"
  group "root"
  mode "0644"
end

service "watchdog" do
  action [:enable, :start]
end
