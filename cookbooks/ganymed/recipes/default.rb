if gentoo?
  package "net-analyzer/ganymed" do
    action :upgrade
    notifies :restart, 'service[ganymed]'
  end
elsif debian_based?
  gem_package "ganymed" do
    action :upgrade
    notifies :restart, 'service[ganymed]'
  end
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
else
  cookbook_file "/etc/init.d/ganymed" do
    source "ganymed.initd"
    owner "root"
    group "root"
    mode "0755"
  end
end

service "ganymed" do
  action [:enable, :start]
end
