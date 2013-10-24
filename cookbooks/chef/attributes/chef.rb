default[:chef][:client][:server_url] = Chef::Config[:chef_server_url]
default[:chef][:binary] = if debian_based?
                            "/usr/local/bin/chef-client"
                          else
                            "/usr/bin/chef-client"
                          end
