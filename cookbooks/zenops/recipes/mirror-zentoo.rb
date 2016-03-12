# portage
directory "/var/cache/mirror/zentoo" do
  owner "root"
  group "root"
  mode "0755"
end

# distfiles
directory "/var/cache/mirror/zentoo/distfiles" do
  owner "root"
  group "root"
  mode "0755"
end

cookbook_file "/usr/local/sbin/update-distfiles-mirror" do
  source "update-distfiles-mirror.sh"
  owner "root"
  group "root"
  mode "0755"
end
