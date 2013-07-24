include_attribute "base"

default[:bash][:rcdir] = case node[:platform]
                         when "mac_os_x"
                           "#{node[:homedir]}/.bash"
                         else
                           root? ? "/etc/bash" : "#{node[:homedir]}/.bash"
                         end
