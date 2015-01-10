if root?
  include_recipe "linux::baselayout"
  include_recipe "linux::locales"
  include_recipe "linux::resolv"
  include_recipe "linux::#{node[:platform]}"
  include_recipe "systemd"
  include_recipe "linux::sysctl"
end

include_recipe "linux::packages"

if root?
  include_recipe "linux::nagios"
end
