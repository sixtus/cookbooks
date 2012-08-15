tag("syslog-server")

include_recipe "syslog"
include_recipe "syslog::tlsbase"

syslog_config "00-server" do
  template "server.conf"
end

if node[:syslog][:archivedir]
  directory node[:syslog][:archivedir] do
    owner "root"
    group "root"
    mode 0755
  end

  cron "syslog_gz" do
    minute "0"
    hour "4"
    command "find #{node[:syslog][:archivedir]}/$(date +\\%Y) -type f -mtime +1 -exec gzip -q {} \\;"
  end

  cron "syslog_punt_old" do
    minute "0"
    hour "2"
    command "find #{node[:syslog][:archivedir]} -type f -mtime +180 -delete"
  end

  cron "syslog_archive_current" do
    minute "1"
    hour "0"
    command "ln -nfs #{node[:syslog][:archivedir]}/$(date +%Y/%m/%d) #{node[:syslog][:archivedir]}/current"
  end
else
  cron "syslog_gz" do
    action :delete
  end

  cron "syslog_punt_old" do
    action :delete
  end

  cron "syslog_archive_current" do
    action :delete
  end
end
