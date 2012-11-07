tag("ganymed-client")

package "net-analyzer/ganymed" do
  action :upgrade
  notifies :restart, 'service[ganymed]'
end

directory "/usr/lib/ganymed" do
  owner "root"
  group "root"
  mode "0755"
end

directory "/usr/lib/ganymed/collectors" do
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/ganymed/config.yml" do
  source "config.yml"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[ganymed]"
end

service "ganymed" do
  action [:enable, :start]
end
