include_attribute "base"

default[:lftp][:configfile] = if mac_os_x?
                                "#{node[:homedir]}/.lftp/rc"
                              elsif gentoo?
                                root? ? "/etc/lftp/lftp.conf" : "#{node[:homedir]}/.lftp/rc"
                              elsif debian_based?
                                root? ? "/etc/lftp.conf" : "#{node[:homedir]}/.lftp/rc"
                              end

default[:lftp][:bookmarks] = {}
