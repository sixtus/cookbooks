default[:tmux][:configfile] = case node[:platform]
                              when "gentoo"
                                "/etc/tmux.conf"
                              when "mac_os_x"
                                "#{node[:homedir]}/.tmux.conf"
                              end
