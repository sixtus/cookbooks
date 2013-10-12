if gentoo?
  package "app-admin/sudo"

elsif debian_based?
  package "sudo"

end

template "/etc/sudoers" do
  source "sudoers"
  owner "root"
  group "root"
  mode "0440"
end
