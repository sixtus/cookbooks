package "net-analyzer/ganymed"

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

processor = node.run_state[:nodes].select do |n|
  n[:tags].include?("ganymed-processor")
end.first

template "/etc/ganymed/config.yml" do
  source "config.yml"
  owner "root"
  group "root"
  mode "0644"
  variables :processor => processor
  notifies :restart, "service[ganymed]"
end

service "ganymed" do
  action [:enable, :start]
end
