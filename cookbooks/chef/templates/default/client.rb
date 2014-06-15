# Configuration File For Chef (chef-client)

node_name "<%= node[:fqdn] %>"
chef_server_url "<%= node[:chef][:client][:server_url] %>"

log_location STDOUT
verbose_logging false
enable_reporting false

<% if ubuntu? %>
# ca-certificates are very broken on ubuntu.
# custom CA certificates are simply ignored.
ssl_verify_mode :verify_none
<% else %>
ssl_verify_mode :verify_peer
<% end %>

file_cache_path "/var/lib/chef/cache"
file_backup_path "/var/lib/chef/backup"

Ohai::Config[:plugin_path] = [<%= node[:ohai][:plugin_path].inspect %>]
