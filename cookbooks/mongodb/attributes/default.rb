default[:mongodb][:cluster] = node[:fqdn]

default[:mongodb][:bind_ip] = "127.0.0.1"
default[:mongodb][:port] = "27017"
default[:mongodb][:dbpath] = "/var/lib/mongodb"
default[:mongodb][:replication][:set] = nil
default[:mongodb][:shardsvr] = false
default[:mongodb][:oplog][:size] = nil
default[:mongodb][:slowms] = 1000
default[:mongodb][:nfiles] = 16384

default[:mongoc][:bind_ip] = "127.0.0.1"
default[:mongoc][:port] = "27117"
default[:mongoc][:dbpath] = "/var/lib/mongoc"
default[:mongoc][:nfiles] = 16384

default[:mongos][:instances] = {}
