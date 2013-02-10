log_level :info
log_location STDOUT

node_name "<%= node_name %>"
client_key "<%= TOPDIR %>/.chef/client.pem"

chef_server_url "https://<%= chef_server_url %>"

cache_type 'BasicFile'
cache_options(:path => "<%= TOPDIR %>/.chef/checksums")

script_path "<%= TOPDIR %>/scripts"

cookbook_path [
  "<%= TOPDIR %>/cookbooks",
  "<%= TOPDIR %>/site-cookbooks"
]
