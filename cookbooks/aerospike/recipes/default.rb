package "dev-db/aerospike"
package "dev-libs/aerospike-client"

if nagios_client?
  nagios_plugin "check_aerospike"
end
