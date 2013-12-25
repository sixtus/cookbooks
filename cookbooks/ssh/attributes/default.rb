include_attribute "base"

if root?
  default[:ssh][:config] = "/etc/ssh/ssh_config"
  default[:ssh][:hostsfile] = "/etc/ssh/ssh_known_hosts"
else
  default[:ssh][:config] = "#{node[:homedir]}/.ssh/config"
  default[:ssh][:hostsfile] = "#{node[:homedir]}/.ssh/known_hosts"
end

default[:ssh][:additional_host_keys] = []

default[:ssh][:server][:password_auth] = "no"
default[:ssh][:server][:challange_response_auth] = "no"
default[:ssh][:server][:root_login] = "no"
default[:ssh][:server][:x11_forwarding] = "yes"
default[:ssh][:server][:use_lpk] = "no"
default[:ssh][:server][:matches] = {}
