if root?
  include_recipe "linux::baselayout"
  include_recipe "linux::locales"
  include_recipe "linux::resolv"
  include_recipe "systemd"
  include_recipe "linux::sysctl"
  include_recipe "linux::#{node[:platform]}"
end

include_recipe "linux::packages"

if root?
  include_recipe "linux::nagios"
end
