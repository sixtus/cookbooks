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
  include_recipe "duply"

  duply_backup "etc" do
    source "/etc"
  end

  duply_backup "home" do
    source "/home"
  end

  duply_backup "root" do
    source "/root"
  end
end
