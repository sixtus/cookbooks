# Configuration File For Chef (knife)

node_name          "<%= @node_name %>"
client_key         "<%= @client_key %>"

log_level          :info
log_location       STDOUT

ssl_verify_mode    :verify_none
chef_server_url    "<%= node[:chef][:client][:server_url] %>"

<% if @node_name == "root" %>
cookbook_path      ["/root/chef/cookbooks", "/root/chef/site-cookbooks"]
<% end %>
