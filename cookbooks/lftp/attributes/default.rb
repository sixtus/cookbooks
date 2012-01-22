default[:lftp][:configfile] = case node[:platform]
                              when "gentoo"
                                "/etc/lftp/lftp.conf"
                              when "mac_os_x"
                                "#{node[:homedir]}/.lftp/rc"
                              end

default[:lftp][:bookmarks] = {}
