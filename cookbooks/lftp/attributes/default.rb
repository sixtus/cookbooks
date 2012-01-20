default[:lftp][:configfile] = case platform
                              when "gentoo"
                                "/etc/lftp/lftp.conf"
                              when "mac_os_x"
                                "/usr/local/etc/lftp.conf"
                              end

default[:lftp][:bookmarks] = {}
