# Configuration File For Chef (chef-server)

require "madvertise-logging"

ImprovedLogger.class_eval do
  attr_accessor :sync, :formatter
end

log_level :warn
log_location ImprovedLogger.new(:syslog, "chef-client")

ssl_verify_mode :verify_none
signing_ca_path "/etc/chef/certificates"
signing_ca_cert "/etc/chef/certificates/cert.pem"
signing_ca_key "/etc/chef/certificates/key.pem"

checksum_path "/var/lib/chef/checksums"
sandbox_path "/var/lib/chef/sandboxes"
search_index_path "/var/lib/chef/search_index"
file_cache_path "/var/lib/chef/cache"
file_backup_path "/var/lib/chef/backup"

amqp_pass "<%= @amqp_pass %>"
