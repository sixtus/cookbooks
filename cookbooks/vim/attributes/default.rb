include_attribute "base"

if root?
  default[:vim][:rcdir] = "/etc/vim"
  default[:vim][:rcfile] = "#{node[:vim][:rcdir]}/vimrc.local"
else
  default[:vim][:rcdir] = "#{node[:homedir]}/.vim"
  default[:vim][:rcfile] = "#{node[:homedir]}/.vimrc"
end
