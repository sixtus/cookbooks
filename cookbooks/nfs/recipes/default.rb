package "net-fs/nfs-utils"

service "rpcbind.service" do
  action [:enable, :start]
end

systemd_unit "rpc-mountd.service"

service "rpc-mountd.service" do
  action [:enable, :start]
end

systemd_unit "rpc-statd.service"

service "rpc-statd.service" do
  action [:enable, :start]
end
