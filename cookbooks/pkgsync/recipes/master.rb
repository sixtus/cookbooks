tag("pkgsync-master")

node[:pkgsync][:password] = get_password("pkgsync")

clients = node.run_state[:nodes].select do |n|
  n[:tags].include?("pkgsync-client")
end

file "/etc/pkgsync.secret" do
  content node[:pkgsync][:password]
  owner "root"
  group "root"
  mode "0600"
end

template "/usr/sbin/pkgsync" do
  source "pkgsync.erb"
  owner "root"
  group "root"
  mode "0755"
  variables :clients => clients
end

cron_hourly "pkgsync" do
  command "/usr/sbin/pkgsync"
end
