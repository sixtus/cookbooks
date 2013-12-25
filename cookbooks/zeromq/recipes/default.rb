if gentoo?
  package "net-libs/zeromq"
elsif mac_os_x?
  package "zeromq"
else
  raise "cookbook zeromq does not support platform #{node[:platform]}"
end
