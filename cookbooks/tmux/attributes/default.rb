include_attribute "base"

default[:tmux][:configfile] = if mac_os_x?
                                "#{node[:homedir]}/.tmux.conf"
                              else
                                root? ? "/etc/tmux.conf" : "#{node[:homedir]}/.tmux.conf"
                              end
