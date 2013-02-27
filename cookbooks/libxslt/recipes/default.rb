case node[:platform]
when /gentoo/
  package "dev-libs/libxslt"

when /mac_os_x/
  package "libxslt"

end
