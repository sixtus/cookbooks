include_recipe "druid"

directory "/var/app/druid/config/broker" do
  owner "druid"
  group "druid"
  mode "0755"
end

template "/var/app/druid/config/broker/runtime.properties" do
  source "runtime.properties"
  owner "root"
  group "root"
  mode "0644"
  variables service: "broker"
end

template "/var/app/druid/bin/druid-broker" do
  source "runner.sh"
  owner "root"
  group "root"
  mode "0755"
  variables service: "broker"
end

systemd_unit "druid-broker.service" do
  template "druid.service"
end

service "druid-broker" do
  action [:enable, :start]
  subscribes :restart, "template[/var/app/druid/config/_common/common.runtime.properties]"
  subscribes :restart, "template[/var/app/druid/config/broker/runtime.properties]"
  subscribes :restart, "template[/var/app/druid/config/log4j.properties]"
  subscribes :restart, "template[/var/app/druid/bin/druid-broker]"
  subscribes :restart, "systemd_unit[druid-broker.service]"
end
