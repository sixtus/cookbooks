case node[:platform]
when "gentoo"
  package "net-analyzer/nrpe" do
    action :upgrade
  end

  portage_package_keywords "net-analyzer/nagios-check_pidfile"

  package "net-analyzer/nagios-check_pidfile"

  cookbook_file "/etc/init.d/nrpe" do
    source "nrpe.initd"
    owner "root"
    group "root"
    mode "0755"
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
  service_name "nagios-nrpe-server" if node[:platform] == "debian"
  action [:enable, :start]
  supports [:reload]
end
