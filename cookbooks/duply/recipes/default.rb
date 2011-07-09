package "app-backup/duply"

%w(
  /etc/duply
  /var/tmp/backup
  /var/cache/backup
).each do |d|
  directory d do
    owner "root"
    group "root"
    mode "0700"
  end
end

# nagios checks
nagios_plugin "check_duplybackup"

node.set[:lftp][:bookmarks][:backup] = node[:backup][:target_base_url].sub(/^ssh:/, "sftp:")

node[:backup][:configs].each do |name, params|
  directory "/etc/duply/#{name}" do
    owner "root"
    group "root"
    mode "0700"
  end

  directory "/var/log/duply/#{name}" do
    owner "root"
    group "root"
    mode "0755"
    recursive true
  end

  template "/etc/duply/#{name}/conf" do
    source "duply.conf"
    owner "root"
    group "root"
    mode "0600"
    variables(params)
  end

  cron_daily "duply-bkp-#{name}" do
    command "/usr/bin/duply #{name} bkp > /var/log/duply/#{name}/$(date +%Y-%m-%d).log"
  end

  cron_weekly "duply-purge-#{name}" do
    command "/usr/bin/duply #{name} purge-full --force &> /dev/null"
  end

  nrpe_command "check_duplybackup_#{name}" do
    command "/usr/lib/nagios/plugins/check_duplybackup #{name}"
  end

  nagios_service "DUPLYBACKUP-#{name.upcase}" do
    check_command "check_nrpe!check_duplybackup_#{name}"
    normal_check_interval 1440
    notification_interval 180
  end
end
