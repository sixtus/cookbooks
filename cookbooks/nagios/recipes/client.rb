unless node[:skip][:nagios_client]
  tag("nagios-client")
  include_recipe "munin::node"
  include_recipe "nagios::nrpe"
  include_recipe "nagios::nsca"
end
