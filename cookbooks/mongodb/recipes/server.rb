opts = %w(--journal --rest --quiet)
opts << "--shardsvr" if node[:mongodb][:shardsvr]
opts << "--replSet #{node[:mongodb][:replication][:set]}" if node[:mongodb][:replication][:set]

mongodb_instance "mongodb" do
  dbpath node[:mongodb][:dbpath]
  bind_ip node[:mongodb][:bind_ip]
  port node[:mongodb][:port]
  opts opts
end
