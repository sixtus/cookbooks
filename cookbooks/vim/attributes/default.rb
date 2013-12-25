include_attribute "base"

default[:vim][:rcfile] = if mac_os_x?
                           "#{node[:homedir]}/.vimrc"
                         else
                           root? ? "/etc/vim/vimrc.local" : "#{node[:homedir]}/.vimrc"
                         end

default[:vim][:rcdir] = if mac_os_x?
                          "#{node[:homedir]}/.vim"
                        else
                          root? ? "/etc/vim" : "#{node[:homedir]}/.vim"
                        end
