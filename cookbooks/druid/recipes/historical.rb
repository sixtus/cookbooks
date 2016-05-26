include_recipe "druid"

directory "/var/app/druid/config/historical" do
  owner "druid"
  group "druid"
  mode "0755"
end

template "/var/app/druid/config/historical/runtime.properties" do
  source "runtime.properties"
  owner "root"
  group "root"
  mode "0644"
  variables service: "historical"
end

template "/var/app/druid/bin/druid-historical" do
  source "runner.sh"
  owner "root"
  group "root"
  mode "0755"
  variables service: "historical"
end

systemd_unit "druid-historical.service" do
  template "druid.service"
end

service "druid-historical" do
  action [:enable, :start]
  subscribes :restart, "template[/var/app/druid/config/_common/common.runtime.properties]"
  subscribes :restart, "template[/var/app/druid/config/historical/runtime.properties]"
  subscribes :restart, "template[/var/app/druid/config/log4j.properties]"
  subscribes :restart, "template[/var/app/druid/bin/druid-historical]"
  subscribes :restart, "systemd_unit[druid-historical.service]"
end
