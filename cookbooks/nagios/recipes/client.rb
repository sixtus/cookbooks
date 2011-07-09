unless node[:skip][:nagios_client]
  tag("nagios-client")
  include_recipe "nagios::nrpe"
  include_recipe "nagios::nsca"
end
