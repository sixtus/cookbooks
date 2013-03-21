include_recipe "postgresql"

package "dev-db/postgresql-server"

datadir = "/var/lib/postgresql/9.1/data"
confdir = "/etc/postgresql-9.1"

directory datadir do
  owner "postgres"
  group "postgres"
  mode "0700"
  recursive true
end

execute "postgresql-initdb" do
  command "/usr/lib/postgresql-9.1/bin/initdb --pgdata #{datadir} --locale=en_US.UTF-8"
  user "postgres"
  group "postgres"
  creates File.join(datadir, "PG_VERSION")
end

template "#{confdir}/postgresql.conf" do
  source "postgresql.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  variables :p => node[:postgresql][:server]
  notifies :reload, "service[postgresql-9.1]"
end

template "#{confdir}/pg_hba.conf" do
  source "pg_hba.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  notifies :reload, "service[postgresql-9.1]"
end

template "#{confdir}/pg_ident.conf" do
  source "pg_ident.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  notifies :reload, "service[postgresql-9.1]"
end

systemd_tmpfiles "postgresql"
systemd_unit "postgresql@.service"

service "postgresql-9.1" do
  service_name "postgresql@9.1.service" if systemd_running?
  action [:enable, :start]
  supports [:reload]
end
