default[:git][:email] = node[:current_email]
default[:git][:name] = node[:current_name]

default[:git][:github][:user] = nil

default[:git][:rcfile] = case node[:platform]
                         when "gentoo"
                           root? ? "/etc/gitconfig" : "#{node[:homedir]}/.gitconfig"
                         when "mac_os_x"
                           "#{node[:homedir]}/.gitconfig"
                         end

default[:git][:exfile] = case node[:platform]
                         when "gentoo"
                           root? ? "/etc/gitignore" : "#{node[:homedir]}/.gitignore"
                         when "mac_os_x"
                           "#{node[:homedir]}/.gitignore"
                         end
