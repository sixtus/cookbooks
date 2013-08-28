package "app-portage/layman"

cookbook_file "/etc/layman/layman.cfg" do
  source "layman.cfg"
  owner "root"
  group "root"
  mode "0644"
  backup 0
end

directory "/var/lib/layman" do
  owner "root"
  group "root"
  mode "0755"
end

template "/var/lib/layman/overlays.xml" do
  source "overlays.xml"
  owner "root"
  group "root"
  mode "0644"
end

file "/var/lib/layman/make.conf" do
  content %{PORTDIR_OVERLAY=""\n}
  owner "root"
  group "root"
  mode "0644"
  only_if { File.size?("/var/lib/layman/make.conf").nil? }
end

if !zentoo?
  portage_overlay "zentoo"
end
