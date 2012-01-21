default[:lftp][:configfile] = case platform
                              when "gentoo"
                                "/etc/lftp/lftp.conf"
                              when "mac_os_x"
                                "#{node[:homedir]}/.lftp/rc"
                              end

default[:lftp][:bookmarks] = {}
