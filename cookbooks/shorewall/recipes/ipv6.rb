package "net-firewall/shorewall6"

execute "shorewall6-restart" do
  command "/sbin/shorewall6 restart"
  action :nothing
end

directory "/etc/shorewall6" do
  owner "root"
  group "root"
  mode "0700"
end

template "/etc/shorewall6/shorewall6.conf" do
  source "ipv6/shorewall6.conf"
  owner "root"
  group "root"
  mode "0600"
  notifies :run, "execute[shorewall6-restart]"
end

%w(
  hosts
  interfaces
  policy
  rules
  tunnels
  zones
).each do |t|
  template "/etc/shorewall6/#{t}" do
    source "ipv6/#{t}"
    owner "root"
    group "root"
    mode "0600"
    notifies :run, "execute[shorewall6-restart]"
  end
end

directory "/var/lock/subsys"

service "shorewall6" do
  action [:enable, :start]
end
