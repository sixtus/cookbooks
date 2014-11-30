if root?
  include_recipe "linux::baselayout"
  include_recipe "linux::locales"
  include_recipe "linux::resolv"
  include_recipe "systemd"
  include_recipe "linux::sysctl"
  include_recipe "linux::#{node[:platform]}"
end

include_recipe "linux::packages"

file "/.agignore" do
  content([
    "dev/",
    "proc/",
    "run/",
    "sys/",
    "tmp/",
    "var/lib/chef/backup",
    "var/lib/syslog-ng/syslog-ng.ctl",
    "var/log/",
    "var/spool/",
  ].join("\n"))
  owner "root"
  group "root"
  mode "0644"
end

if root?
  include_recipe "linux::nagios"

  cron_daily "xfs_fsr" do
    command "/usr/sbin/xfs_fsr -t 600"
    action :delete
  end
end
