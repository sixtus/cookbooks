package "net-analyzer/nagios-nrpe"
package "net-analyzer/nagios-check_pidfile"

directory "/etc/nagios" do
  owner "nagios"
  group "nagios"
  mode "0750"
end

directory "/etc/nagios/nrpe.d" do
  owner "nagios"
  group "nagios"
  mode "0750"
end

template "/etc/nagios/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "nagios"
  group "nagios"
  mode "0640"
  notifies :restart, "service[nrpe]"
end

cookbook_file "/etc/init.d/nrpe" do
  source "nrpe.initd"
  owner "root"
  group "root"
  mode "0755"
end

service "nrpe" do
  action [:enable, :start]
end
