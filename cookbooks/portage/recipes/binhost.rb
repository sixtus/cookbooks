tag("portage-binhost")

clients = node.run_state[:nodes].select do |n|
  n[:primary_ipaddress]
end.map do |n|
  n[:primary_ipaddress]
end

directory "/var/cache/portage/packages" do
  owner "root"
  group "root"
  mode "0755"
end

template "/usr/sbin/pkgsync" do
  source "pkgsync.sh"
  owner "root"
  group "root"
  mode "0755"
  variables :clients => clients
end

cron_hourly "pkgsync" do
  command "/usr/sbin/pkgsync"
end

nginx_server "binhost" do
  template "binhost.nginx.conf"
end
