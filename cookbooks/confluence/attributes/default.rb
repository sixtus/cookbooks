default[:confluence][:download_url] = "http://downloads.atlassian.com/software/confluence/downloads/atlassian-confluence-5.3.tar.gz"

default[:confluence][:server_name] = "confluence.#{node[:chef_domain]}"
default[:confluence][:certificate] = "wildcard.#{node[:chef_domain]}"
