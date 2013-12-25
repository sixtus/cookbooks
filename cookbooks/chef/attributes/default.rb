default[:chef][:client][:server_url] = Chef::Config[:chef_server_url]

if debian_based?
  default[:chef][:binary] = "/usr/local/bin/chef-client"
else
  default[:chef][:binary] = "/usr/bin/chef-client"
end
