include_attribute "base"

default[:lftp][:configfile] = case node[:platform]
                              when "mac_os_x"
                                "#{node[:homedir]}/.lftp/rc"
                              when "gentoo"
                                root? ? "/etc/lftp/lftp.conf" : "#{node[:homedir]}/.lftp/rc"
                              when "debian"
                                root? ? "/etc/lftp.conf" : "#{node[:homedir]}/.lftp/rc"
                              end

default[:lftp][:bookmarks] = {}
