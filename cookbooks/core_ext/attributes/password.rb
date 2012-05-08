default[:password][:directory] = if root?
                                   "/var/lib/chef/passwords"
                                 else
                                   "#{node[:homedir]}/.chef/passwords"
                                 end
