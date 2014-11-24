default[:nagios][:server_name] = "nagios.#{node[:chef_domain]}"
default[:nagios][:certificate] = "wildcard.#{node[:chef_domain]}"
default[:nagios][:from_address] = "nagios@#{node[:fqdn]}"
default[:nagios][:nsca][:password] = "n6JlHK3zql33QpQiiNWk1rC5XQsDk8KB"
default[:nagios][:notifier] = "noop"
default[:nagios][:notes][:base_url] = "https://github.com/zenops/cookbooks/blob/master/documentation/alerts"

if node.clustered?
  default[:nagios][:vhosts] = ["#{node.cluster_domain}"]
else
  default[:nagios][:vhosts] = []
end
