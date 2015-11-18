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

template "#{datadir}/recovery.conf" do
  action(postgresql_hot_standby? ? :create : :delete)

  source "recovery.conf"
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

backupdir = "/var/app/postgresql/backup"
backup_active = postgresql_master? and production?

if backup_active
  directory backupdir do
    owner "postgres"
    group "postgres"
    mode "0700"
    recursive true
  end
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
  action :delete unless backup_active
end

duply_backup "postgresql" do
  source backupdir
  max_full_backups 30
  incremental false
  action :delete unless backup_active
end

if node[:postgresql][:snapshot][:active]
  directory node[:postgresql][:snapshot][:path] do
    owner "postgres"
    group "postgres"
    mode "0700"
    recursive true
  end

  template "/var/app/postgresql/postgres-snapshot" do
    source "postgres-snapshot.sh"
    owner "postgres"
    group "postgres"
    mode "0544"
  end
end

systemd_timer "postgresql-snapshot" do
  schedule %w(OnCalendar=hourly)
  unit({
    command: [
      "/var/app/postgresql/postgres-snapshot"
    ],
    user: "postgres",
    group: "postgres",
  })
  action :delete unless node[:postgresql][:snapshot][:active]
end

if postgresql_master? && nagios_client?
  nagios_plugin "check_postgres" do
    source "check_postgres.rb"
  end

  nrpe_command "check_postgres_replication_lag" do
    command "/usr/lib/nagios/plugins/check_postgres --user=postgres -m ReplicationLag -w 100 -c 300"
  end

  nagios_service "POSTGRES-REPLICATION-LAG" do
    check_command "check_nrpe!check_postgres_replication_lag"
    servicegroups "postgres"
  end
end

if postgresql_hot_standby? && nagios_client?
  nagios_plugin "check_postgres_slave" do
    source "check_postgres_slave.rb"
  end

  nrpe_command "check_postgres_slave_lag" do
    command "/usr/lib/nagios/plugins/check_postgres_slave -w 60 -c 180"
  end

  nagios_service "POSTGRES-SLAVE-LAG" do
    check_command "check_nrpe!check_postgres_slave_lag"
    servicegroups "postgres"
  end
end
