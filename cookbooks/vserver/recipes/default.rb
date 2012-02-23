package "sys-cluster/util-vserver"

%w(vprocunhide util-vserver vservers.default).each do |s|
  service s do
    action [:enable, :start]
  end
end

cookbook_file "/etc/vservers/.defaults/fstab" do
  source "fstab"
  owner "root"
  group "root"
  mode "0644"
end

template "/etc/vservers/.defaults/files/resolv.conf" do
  source "resolv.conf"
  owner "root"
  group "root"
  mode "0644"
end

file "/usr/sbin/viotop" do
  action :delete
end

%w(
  mkvs
  viotop
  vrename
).each do |f|
  cookbook_file "/usr/local/sbin/#{f}" do
    source "scripts/#{f}"
    owner "root"
    group "root"
    mode "0755"
  end
end
