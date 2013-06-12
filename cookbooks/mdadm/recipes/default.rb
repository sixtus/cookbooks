case node[:platform]
when "gentoo"
  portage_package_use "sys-fs/mdadm" do
    use %w(static)
  end

  package "sys-fs/mdadm"

when "debian"
  package "mdadm"
end

service "mdadm" do
  action [:disable, :stop]
end

template "/etc/mdadm.conf" do
  source "mdadm.conf"
  owner "root"
  group "root"
  mode "0644"
end
