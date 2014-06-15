include_recipe "postgresql"

package "dev-db/postgresql-server"

pkg = package "dev-ruby/pg" do
  action :nothing
end
pkg.run_action(:install)
Gem.clear_paths

version = "9.3"
datadir = "/var/lib/postgresql/#{version}/data"

directory datadir do
  owner "postgres"
  group "postgres"
  mode "0700"
  recursive true
end

directory "#{datadir}/pg_log_archive" do
  owner "postgres"
  group "postgres"
  mode "0700"
end

directory "#{datadir}/pg_backup" do
  owner "postgres"
  group "postgres"
  mode "0700"
end

execute "postgresql-initdb" do
  command "/usr/lib/postgresql-#{version}/bin/initdb --pgdata #{datadir} --locale=en_US.UTF-8"
  user "postgres"
  group "postgres"
  creates File.join(datadir, "PG_VERSION")
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

# set password only on master
if node[:postgresql][:server][:hot_standby] == "off"
  pg_pass = get_password("postgresql/postgres")

  bash "postgresql-password" do
    user "postgres"
    code <<-EOH
  echo "ALTER ROLE postgres PASSWORD '#{pg_pass}';" | psql
    EOH
    not_if do
      begin
        require 'pg'
        PGconn.connect("localhost", 5432, nil, nil, nil, "postgres", pg_pass)
      rescue LoadError
        Chef::Log.warn("ruby postgres driver missing. skipping postgresql-password")
        true
      rescue
        false
      end
    end
  end
end

systemd_timer "postgresql-backup" do
  schedule %w(OnCalendar=daily)
  unit({
    command: "/usr/bin/pg_basebackup -D #{datadir}/pg_backup -Ft -z -x",
    user: "postgres",
    group: "postgres",
  })
end

duply_backup "postgresql" do
  source "#{datadir}/pg_backup"
  max_full_backups 30
  max_full_age "1D"
end
