default[:ssh][:config] = case node[:platform]
                         when "mac_os_x"
                           "#{node[:homedir]}/.ssh/config"
                         else
                           root? ? "/etc/ssh/ssh_config" : "#{node[:homedir]}/.ssh/config"
                         end

default[:ssh][:hostsfile] = case node[:platform]
                            when "mac_os_x"
                              "#{node[:homedir]}/.ssh/known_hosts"
                            else
                              root? ? "/etc/ssh/ssh_known_hosts" : "#{node[:homedir]}/.ssh/known_hosts"
                            end

default[:ssh][:additional_host_keys] = []

default[:ssh][:server][:password_auth] = "no"
default[:ssh][:server][:challange_response_auth] = "no"
default[:ssh][:server][:root_login] = "no"
default[:ssh][:server][:x11_forwarding] = "yes"
default[:ssh][:server][:use_lpk] = "no"
default[:ssh][:server][:matches] = {}
