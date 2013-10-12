include_attribute "base"

default[:bash][:rcdir] = if mac_os_x?
                           "#{node[:homedir]}/.bash"
                         else
                           root? ? "/etc/bash" : "#{node[:homedir]}/.bash"
                         end
