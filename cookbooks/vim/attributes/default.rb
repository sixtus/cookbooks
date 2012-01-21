default[:vim][:rcfile] = case platform
                         when "gentoo"
                           "/etc/vim/vimrc.local"
                         when "mac_os_x"
                           "#{node[:homedir]}/.vimrc"
                         end
