default[:ssh][:config] = case node[:platform]
                         when "gentoo"
                           root? ? "/etc/ssh/ssh_config" : "#{node[:homedir]}/.ssh/config"
                         when "mac_os_x"
                           "#{node[:homedir]}/.ssh/config"
                         end

default[:ssh][:additional_host_keys] = []

default[:ssh][:server][:password_auth] = "no"
default[:ssh][:server][:challange_response_auth] = "no"
default[:ssh][:server][:root_login] = "no"
default[:ssh][:server][:x11_forwarding] = "no"
default[:ssh][:server][:use_lpk] = "no"
default[:ssh][:server][:matches] = {}

default[:denyhosts][:whitelist] = []
