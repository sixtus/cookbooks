default[:zendns][:server_name] = node[:fqdn]

default[:zendns][:ssl][:cn] = node[:fqdn]

default[:zendns][:port] = 3000
default[:zendns][:homedir] = "/var/app/zendns"
default[:zendns][:deployers] = []
