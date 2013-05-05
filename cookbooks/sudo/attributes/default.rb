default[:sudo][:nopasswd] = "true"
default[:sudo][:rules] = {}
default[:sudo][:group] = case node[:platform]
                         when "debian"
                           "sudo"
                         when "gentoo"
                           "wheel"
                         end
