default[:sudo][:nopasswd] = true
default[:sudo][:rules] = {}

if debian_based?
  default[:sudo][:group] = "sudo"
elsif gentoo?
  default[:sudo][:group] = "wheel"
end
