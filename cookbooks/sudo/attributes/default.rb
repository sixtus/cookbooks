default[:sudo][:nopasswd] = "true"
default[:sudo][:rules] = {}
default[:sudo][:group] = if debian_based?
                           "sudo"
                         elsif gentoo?
                           "wheel"
                         end
