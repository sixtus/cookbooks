default[:zookeeper][:ensemble] = node[:fqdn] # do not cluster by default

default[:zookeeper][:confdir] = case node[:platform]
                                when "gentoo"
                                  "/opt/zookeeper/conf"
                                when "mac_os_x"
                                  "/usr/local/etc/zookeeper"
                                end

default[:zookeeper][:bindir] = case node[:platform]
                               when "gentoo"
                                 "/opt/zookeeper/bin"
                               when "mac_os_x"
                                 "/usr/local/bin"
                               end

default[:zookeeper][:datadir] = case node[:platform]
                                when "gentoo"
                                  "/var/lib/zookeeper"
                                when "mac_os_x"
                                  "/usr/local/var/zookeeper"
                                end
