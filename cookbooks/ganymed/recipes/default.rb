if gentoo?
  package "net-analyzer/ganymed"
elsif debian_based?
  gem_package "ganymed"
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

directory "/etc/ganymed" do
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

if systemd_running?
  systemd_unit "ganymed.service"

  service "ganymed" do
    action [:enable, :start]
  end
end
