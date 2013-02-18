tag("ganymed-client")

package "net-analyzer/ganymed" do
  action :upgrade
  notifies :restart, 'service[ganymed]'
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

template "/etc/ganymed/config.yml" do
  source "config.yml"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[ganymed]"
end

systemd_unit "ganymed.service"

service "ganymed" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_ganymed" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/ganymed.pid ganymed"
  end

  nagios_service "GANYMED" do
    check_command "check_nrpe!check_ganymed"
    env [:testing, :development]
  end
end
