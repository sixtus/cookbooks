package "sys-cluster/ceph"

%w(
  /var/lib/ceph
  /var/lib/ceph/tmp
  /var/lib/ceph/mon
).each do |d|
  directory d do
    owner "root"
    group "root"
    mode "0755"
  end
end
