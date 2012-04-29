default[:bash][:rcdir] = case node[:platform]
                         when "gentoo"
                           root? ? "/etc/bash" : "#{node[:homedir]}/.bash"
                         when "mac_os_x"
                           "#{node[:homedir]}/.bash"
                         end
