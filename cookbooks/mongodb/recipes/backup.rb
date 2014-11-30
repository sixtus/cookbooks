%w(
  mongodb_full_backup
  mongodb_full_clean
).each do |f|
  template "/usr/local/sbin/#{f}" do
    source "#{f}.sh"
    owner "root"
    group "root"
    mode "0750"
  end
end

directory node[:mongodb][:backup][:dir] do
  owner "root"
  group "root"
  mode "0755"
  recursive true
end

systemd_timer "mongodb-backup" do
  schedule %W(OnCalendar=#{node[:mongodb][:backup][:full_backup][0]}:#{node[:mongodb][:backup][:full_backup][1]})
  unit({
    command: "/usr/local/sbin/mongodb_full_backup",
    user: "root",
    group: "root",
  })
end

systemd_timer "mongodb-clean" do
  schedule %W(OnCalendar=#{node[:mongodb][:backup][:full_clean][0]}:#{node[:mongodb][:backup][:full_clean][1]})
  unit({
    command: "/usr/local/sbin/mongodb_full_clean",
    user: "root",
    group: "root",
  })
end
