case node[:platform]
when "gentoo"
  package "sys-process/htop"

when "mac_os_x"
  package "htop-osx"
end

directory "#{node[:homedir]}/.config/htop" do
  recursive true
  mode "0755"
end

cookbook_file "#{node[:homedir]}/.config/htop/htoprc" do
  source "htoprc"
  mode "0644"
end
