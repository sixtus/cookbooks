package "net-misc/memcached"

systemd_unit "memcached.service" do
  template true
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
