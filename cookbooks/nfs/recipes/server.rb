include_recipe "nfs"

systemd_unit "nfs-mountd.service"

service "nfs-mountd.service" do
  action [:enable, :start]
end

systemd_unit "nfs-server.service"

service "nfs-server" do
  action [:enable, :start]
end

duply_backup "nfs-exports" do
  source "/etc/exports"
end
