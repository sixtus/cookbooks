package "sys-fs/zfs"

service "zfs" do
  action [:enable, :start]
end
