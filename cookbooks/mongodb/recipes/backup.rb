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
  mode "0700"
  recursive true
end

cron "mongodb_full_backup" do
  action action
  minute node[:mongodb][:backup][:full_backup][1]
  hour node[:mongodb][:backup][:full_backup][0]
  command "/usr/local/sbin/mongodb_full_backup"
end

cron "mongodb_full_clean" do
  action action
  minute node[:mongodb][:backup][:full_clean][1]
  hour node[:mongodb][:backup][:full_clean][0]
  command "/usr/local/sbin/mongodb_full_clean"
end
