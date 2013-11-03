default[:jenkins][:server_name] = "jenkins.#{node[:chef_domain]}"
default[:jenkins][:certificate] = "wildcard.#{node[:chef_domain]}"
