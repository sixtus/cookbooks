package "dev-db/aerospike"

if nagios_client?
  nagios_plugin "check_aerospike"
end
