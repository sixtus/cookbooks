default[:lftp][:configfile] = case node[:platform]
                              when "gentoo"
                                root? ? "/etc/lftp/lftp.conf" : "#{node[:homedir]}/.lftp/rc"
                              when "mac_os_x"
                                "#{node[:homedir]}/.lftp/rc"
                              end

default[:lftp][:bookmarks] = {}
