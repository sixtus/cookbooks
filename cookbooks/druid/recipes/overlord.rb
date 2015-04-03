include_recipe "druid"

directory "/var/app/druid/config/overlord" do
  owner "druid"
  group "druid"
  mode "0755"
end

template "/var/app/druid/config/overlord/runtime.properties" do
  source "runtime.properties"
  owner "root"
  group "root"
  mode "0644"
  variables service: "overlord"
end

template "/var/app/druid/bin/druid-overlord" do
  source "runner.sh"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[druid-overlord]"
  variables service: "overlord"
end

systemd_unit "druid-overlord.service" do
  template "druid.service"
  notifies :restart, "service[druid-overlord]"
end

service "druid-overlord" do
  action [:enable, :start]
  subscribes :restart, "template[/var/app/druid/config/overlord/runtime.properties]"
  subscribes :restart, "template[/var/app/druid/config/log4j.properties]"
  subscribes :restart, "template[/var/app/druid/bin/druid-overlord]"
  subscribes :restart, "systemd_unit[druid-overlord]"
end
