include_recipe "java"

portage_package_use "sys-cluster/ceph" do
  use %w(hadoop radosgw tcmalloc)
end

package "sys-cluster/ceph"

%w(
  /var/lib/ceph
  /var/lib/ceph/tmp
  /var/lib/ceph/mon
  /var/run/ceph
).each do |d|
  directory d do
    owner "root"
    group "root"
    mode "0755"
  end
end
