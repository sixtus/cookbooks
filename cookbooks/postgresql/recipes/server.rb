include_recipe "postgresql"

version = "9.4"
homedir = "/var/lib/postgresql/#{version}"
datadir = "#{homedir}/data"

node.set[:postgresql][:connection][:host] = node[:fqdn]

directory datadir do
  owner "postgres"
  group "postgres"
  mode "0700"
  recursive true
end

execute "postgresql-initdb" do
  command "/usr/lib/postgresql-#{version}/bin/initdb --pgdata #{datadir} --locale=en_US.UTF-8"
  user "postgres"
  group "postgres"
  creates File.join(datadir, "PG_VERSION")
end

directory "#{datadir}/pg_log_archive" do
  owner "postgres"
  group "postgres"
  mode "0700"
end

template "#{datadir}/postgresql.conf" do
  source "postgresql.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  notifies :reload, "service[postgresql]"
  variables datadir: datadir
end

template "#{datadir}/pg_hba.conf" do
  source "pg_hba.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  notifies :reload, "service[postgresql]"
end

template "#{datadir}/pg_ident.conf" do
  source "pg_ident.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  notifies :reload, "service[postgresql]"
end

directory "/etc/postgresql-#{version}" do
  action :delete
  recursive true
end

systemd_tmpfiles "postgresql"
systemd_unit "postgresql@.service"

service "postgresql" do
  service_name "postgresql@#{version}.service"
  action [:enable, :start]
  supports [:reload]
end

backupdir = "#{homedir}/backup"

directory backupdir do
  owner "postgres"
  group "postgres"
  mode "0700"
end

if postgresql_nodes.first
  primary = (node[:fqdn] == postgresql_nodes.first[:fqdn])
else
  primary = true
end

systemd_timer "postgresql-backup" do
  schedule %w(OnCalendar=daily)
  unit({
    command: [
      "/bin/bash -c 'rm -rf #{backupdir}/*'",
      "/usr/bin/pg_basebackup -D #{backupdir} -x",
    ],
    user: "postgres",
    group: "postgres",
  })
  action :delete unless primary
end

duply_backup "postgresql" do
  source backupdir
  max_full_backups 30
  incremental false
  action :delete unless primary
end
