include_attribute "base"

if root?
  default[:tmux][:configfile] = "/etc/tmux.conf"
else
  default[:tmux][:configfile] = "#{node[:homedir]}/.tmux.conf"
end
