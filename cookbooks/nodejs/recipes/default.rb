case node[:platform]
when /gentoo/
  package "net-libs/nodejs"

when /mac_os_x/
  package "node"
end
