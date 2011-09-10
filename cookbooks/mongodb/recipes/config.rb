tag("mongoc")

opts = %w(--journal --rest --configsvr)

mongodb_instance "mongoc" do
  dbpath node[:mongoc][:dbpath]
  bind_ip node[:mongoc][:bind_ip]
  port node[:mongoc][:port]
  opts opts
end
