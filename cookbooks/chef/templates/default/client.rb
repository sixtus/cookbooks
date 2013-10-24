# Configuration File For Chef (chef-client)

node_name "<%= node[:fqdn] %>"

log_location STDOUT
verbose_logging false
enable_reporting false

ssl_verify_mode :verify_none
chef_server_url "<%= node[:chef][:client][:server_url] %>"

file_cache_path "/var/lib/chef/cache"
file_backup_path "/var/lib/chef/backup"
