link "/etc/localtime" do
  to "/usr/share/zoneinfo/#{node[:timezone]}"
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
