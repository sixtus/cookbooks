default[:tmux][:configfile] = case platform
                              when "gentoo"
                                "/etc/tmux.conf"
                              when "mac_os_x"
                                "#{node[:homedir]}/.tmux.conf"
                              end
