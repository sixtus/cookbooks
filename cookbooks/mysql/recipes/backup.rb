%w(
  mysql_full_backup
  mysql_full_clean
  mysql_binlog_backup
  mysql_binlog_clean
).each do |f|
  template "/usr/local/sbin/#{f}" do
    source "#{f}.sh"
    owner "root"
    group "root"
    mode "0750"
  end
end

if node[:mysql][:backup][:mode] == "copy"
  directory node[:mysql][:backup][:copy][:dir] do
    owner "root"
    group "root"
    mode "0700"
    recursive true
  end
end

if mysql_nodes.length > 1
  if node[:mysql][:server][:active_master]
    action = :delete
  else
    action = :create
  end
else
  action = :create
end

systemd_timer "mysql_full_backup" do
  action action
  schedule ["OnCalendar=Sun #{node[:mysql][:backup][:full_backup][1]}:0"]
  unit({
    command: "/usr/local/sbin/mysql_full_backup",
    user: "root",
    group: "root",
  })
end

systemd_timer "mysql_full_clean" do
  action action
  schedule ["OnCalendar=Mon #{node[:mysql][:backup][:full_clean][1]}:0"]
  unit({
    command: "/usr/local/sbin/mysql_full_clean",
    user: "root",
    group: "root",
  })
end

systemd_timer "mysql_binlog_backup" do
  action action
  schedule %W(OnCalendar=*:3/30)
  unit({
    command: "/usr/local/sbin/mysql_binlog_backup",
    user: "root",
    group: "root",
  })
end

systemd_timer "mysql_binlog_clean" do
  action action
  schedule ["OnCalendar=Mon #{node[:mysql][:backup][:binlog_clean][1]}:0"]
  unit({
    command: "/usr/local/sbin/mysql_binlog_clean",
    user: "root",
    group: "root",
  })
end
