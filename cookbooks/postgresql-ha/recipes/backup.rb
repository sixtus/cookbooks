include_recipe "postgresql-ha"

backupdir = "/var/app/postgresql/backup"

directory backupdir do
  owner "postgres"
  group "postgres"
  mode "0700"
  recursive true
end

systemd_timer "postgresql-backup" do
  schedule %w(OnCalendar=daily)
  unit({
    command: [
      "/bin/bash -c 'rm -rf #{backupdir}/*'",
      "/usr/bin/pg_basebackup -D #{backupdir} --xlog-method=stream",
    ],
    user: "postgres",
    group: "postgres",
  })
end

duply_backup "postgresql" do
  source backupdir
  max_full_backups 30
  incremental false
end
