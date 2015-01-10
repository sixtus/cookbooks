package "sys-fs/zfs"

service "zfs" do
  action [:enable, :start]
end

# check if quickstart has left us zpool setup instructions
bash "zpool-create" do
  code "set -e; source /zpool-create.sh"
  only_if { File.exist?("/zpool-create.sh") }
end

file "/zpool-create.sh" do
  action :delete
end
