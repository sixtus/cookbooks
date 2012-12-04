# Configuration File For Chef (chef-client)

node_name          "<%= node[:fqdn] %>"

log_level          :info
log_location       "/var/log/chef/client.log"
verbose_logging    false

ssl_verify_mode    :verify_none
chef_server_url    "<%= node[:chef][:client][:server_url] %>"

file_cache_path    "/var/lib/chef/cache"
file_backup_path   "/var/lib/chef/backup"

<% if node[:chef][:client][:airbrake][:key] %>
require "airbrake_handler"
exception_handlers << AirbrakeHandler.new(:api_key => "<%= node[:chef][:client][:airbrake][:key] %>", :notify_host => "<%= node[:chef][:client][:airbrake][:url] %>" )
<% end %>
