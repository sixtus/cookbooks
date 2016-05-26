include_recipe "druid"

directory "/var/app/druid/config/realtime" do
  owner "druid"
  group "druid"
  mode "0755"
end

template "/var/app/druid/config/realtime/runtime.properties" do
  source "runtime.properties"
  owner "root"
  group "root"
  mode "0644"
  variables service: "realtime"
end

file "/var/app/druid/config/realtime/realtime.spec" do
  content druid_realtime_spec.to_json
  owner "root"
  group "root"
  mode "0644"
end

template "/var/app/druid/bin/druid-realtime" do
  source "runner.sh"
  owner "root"
  group "root"
  mode "0755"
  variables service: "realtime"
end

systemd_unit "druid-realtime.service" do
  template "druid.service"
end

service "druid-realtime" do
  action [:enable, :start]
  subscribes :restart, "template[/var/app/druid/config/_common/common.runtime.properties]"
  subscribes :restart, "file[/var/app/druid/config/realtime/realtime.spec]"
  subscribes :restart, "systemd_unit[druid-realtime.service]"
  subscribes :restart, "template[/var/app/druid/bin/druid-realtime]"
  subscribes :restart, "template[/var/app/druid/config/realtime/runtime.properties]"
  subscribes :restart, "template[/var/app/druid/config/log4j.properties]"
end
