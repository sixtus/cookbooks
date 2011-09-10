tag("mongos")

mongos_instance "mongos" do
  bind_ip node[:mongos][:bind_ip]
  port node[:mongos][:port]
  configdb node[:mongos][:configdb]
end
