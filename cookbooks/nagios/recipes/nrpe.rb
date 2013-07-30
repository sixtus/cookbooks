case node[:platform]
when "gentoo"
  package "net-analyzer/nrpe" do
    action :upgrade
  end

when "debian"
  package "nagios-nrpe-server"

end

include_recipe "nagios"

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

systemd_unit "nrpe.service"

service "nrpe" do
  action [:enable, :start]
  supports [:reload]
end
