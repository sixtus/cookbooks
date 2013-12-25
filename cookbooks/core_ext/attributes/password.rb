include_attribute "base"

if root?
  default[:password][:directory] = "/var/lib/chef/passwords"
else
  default[:password][:directory] = "#{node[:homedir]}/.chef/passwords"
end
