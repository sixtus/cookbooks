include_attribute "base"

default[:git][:email] = node[:current_email]
default[:git][:name] = node[:current_name]

default[:git][:github][:user] = nil

if mac_os_x?
  default[:git][:rcfile] = "#{node[:homedir]}/.gitconfig"
  default[:git][:exfile] = "#{node[:homedir]}/.gitignore"
else
  default[:git][:rcfile] = root? ? "/etc/gitconfig" : "#{node[:homedir]}/.gitconfig"
  default[:git][:exfile] = root? ? "/etc/gitignore" : "#{node[:homedir]}/.gitignore"
end
