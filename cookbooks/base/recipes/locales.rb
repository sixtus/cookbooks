link "/etc/localtime" do
  to "/usr/share/zoneinfo/#{node[:timezone]}"
end

file "/etc/timezone" do
  content "#{node[:timezone]}\n"
  owner "root"
  group "root"
  mode "0644"
end

execute "locale-gen" do
  command "/usr/sbin/locale-gen"
  action :nothing
end

template "/etc/locale.gen" do
  owner "root"
  group "root"
  mode "0644"
  source "locale.gen"
  notifies :run, "execute[locale-gen]"
end

template "/etc/locale.conf" do
  source "locale.conf"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/vconsole.conf" do
  source "vconsole.conf"
  owner "root"
  group "root"
  mode "0644"
end
