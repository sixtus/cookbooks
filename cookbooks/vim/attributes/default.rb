default[:vim][:rcfile] = case node[:platform]
                         when "gentoo"
                           "/etc/vim/vimrc.local"
                         when "mac_os_x"
                           "#{node[:homedir]}/.vimrc"
                         end

default[:vim][:rcdir] = case node[:platform]
                        when "gentoo"
                          "/etc/vim"
                        when "mac_os_x"
                          "#{node[:homedir]}/.vim"
                        end
