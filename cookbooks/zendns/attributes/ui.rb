default[:zendns][:primary_nameserver] = "ns.#{node[:chef_domain]}"

default[:zendns][:ui][:host] = node[:fqdn]

default[:zendns][:ui][:worker_processes] = 4
default[:zendns][:ui][:timeout] = 30
