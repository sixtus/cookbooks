default[:confluence][:server_name] = "ci.#{node[:chef_domain]}"
default[:confluence][:certificate] = "wildcard.#{node[:chef_domain]}"
