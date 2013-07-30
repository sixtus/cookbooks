package "sys-apps/newrelic-sysmond"

execute "newrelic-license-key" do
  command "/usr/sbin/nrsysmond-config --set license_key=#{node[:newrelic][:license_key]}"
  only_if { !!node[:newrelic][:license_key] }
end

systemd_unit "newrelic-sysmond.service"

service "newrelic-sysmond" do
  action [:enable, :start]
end
