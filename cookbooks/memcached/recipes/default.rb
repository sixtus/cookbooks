package "net-misc/memcached"

template "/etc/conf.d/memcached" do
  source "memcached.confd.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[memcached]"
end

service "memcached" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  package "dev-perl/Nagios-Plugins-Memcached"

  nrpe_command "check_memcached" do
    command "/usr/bin/check_memcached"
  end

  nagios_service "MEMCACHED" do
    check_command "check_nrpe!check_memcached"
  end
end
