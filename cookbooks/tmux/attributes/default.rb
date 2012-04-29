default[:tmux][:configfile] = case node[:platform]
                              when "gentoo"
                                root? ? "/etc/tmux.conf" : "#{node[:homedir]}/.tmux.conf"
                              when "mac_os_x"
                                "#{node[:homedir]}/.tmux.conf"
                              end
