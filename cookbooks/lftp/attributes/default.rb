include_attribute "base"

if mac_os_x?
  default[:lftp][:configfile] = "#{node[:homedir]}/.lftp/rc"
elsif gentoo?
  default[:lftp][:configfile] = root? ? "/etc/lftp/lftp.conf" : "#{node[:homedir]}/.lftp/rc"
elsif debian_based?
  default[:lftp][:configfile] = root? ? "/etc/lftp.conf" : "#{node[:homedir]}/.lftp/rc"
end

default[:lftp][:bookmarks] = {}
