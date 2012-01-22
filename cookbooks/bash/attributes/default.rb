default[:bash][:rcdir] = case node[:platform]
                         when "gentoo"
                           "/etc/bash"
                         when "mac_os_x"
                           "#{node[:homedir]}/.bash"
                         end
