default[:zookeeper][:ensemble] = node[:fqdn] # do not cluster by default

default[:zookeeper][:confdir] = if gentoo?
                                  "/opt/zookeeper/conf"
                                elsif mac_os_x?
                                  "/usr/local/etc/zookeeper"
                                end

default[:zookeeper][:bindir] = if gentoo?
                                 "/opt/zookeeper/bin"
                               elsif mac_os_x?
                                 "/usr/local/bin"
                               end

default[:zookeeper][:datadir] = if gentoo?
                                  "/var/lib/zookeeper"
                                elsif mac_os_x?
                                  "/usr/local/var/zookeeper"
                                end
