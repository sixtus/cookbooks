case node[:platform]
when "gentoo"
  package "app-admin/sudo"

when "debian"
  package "sudo"

end

template "/etc/sudoers" do
  source "sudoers"
  owner "root"
  group "root"
  mode "0440"
end
