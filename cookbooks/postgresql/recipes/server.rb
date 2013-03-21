include_recipe "postgresql"

package "dev-db/postgresql-server"
package "dev-ruby/pg"

version = "9.1"
datadir = "/var/lib/postgresql/#{version}/data"
confdir = "/etc/postgresql-#{version}"

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

template "#{confdir}/postgresql.conf" do
  source "postgresql.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  variables :p => node[:postgresql][:server]
  notifies :reload, "service[postgresql]"
end

template "#{confdir}/pg_hba.conf" do
  source "pg_hba.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  notifies :reload, "service[postgresql]"
end

template "#{confdir}/pg_ident.conf" do
  source "pg_ident.conf"
  owner "postgres"
  group "postgres"
  mode "0600"
  notifies :reload, "service[postgresql]"
end

systemd_tmpfiles "postgresql"
systemd_unit "postgresql@.service"

service "postgresql" do
  service_name "postgresql-#{version}" unless systemd_running?
  service_name "postgresql@#{version}.service" if systemd_running?
  action [:enable, :start]
  supports [:reload]
end

pg_pass = get_password("postgresql/postgres")

bash "postgresql-password" do
  user "postgres"
  code <<-EOH
echo "ALTER ROLE postgres PASSWORD '#{pg_pass}';" | psql
  EOH
  not_if do
    begin
      require 'pg'
      conn = PGconn.connect("localhost", 5432, nil, nil, nil, "postgres", pg_pass)
    rescue LoadError
      Chef::Log.warn("ruby postgres driver missing. skipping postgresql-password")
      true
    rescue
      false
    end
  end
end
