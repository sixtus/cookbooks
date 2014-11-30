node[:packages].each do |pkg|
  package pkg
end

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

if systemd_running?
  systemd_timer "makewhatis" do
    schedule %w(OnCalendar=daily)
    unit({
      command: "/usr/sbin/makewhatis -u",
      user: "root",
      group: "root",
    })
  end

  systemd_timer "logrotate" do
    schedule %w(OnCalendar=daily)
    unit({
      command: "/usr/sbin/logrotate --verbose /etc/logrotate.conf",
      user: "root",
      group: "root",
    })
  end
end
