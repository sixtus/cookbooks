include_recipe "postgresql-ha"
include_recipe "consul"

version = node[:postgresql][:server][:version]
homedir = "/var/lib/postgresql/#{version}"
datadir = "#{homedir}/data"

node.set[:postgresql][:connection][:host] = node[:fqdn]

[
  "/var/app/postgresql",
  "/var/app/postgresql/template",
  "/var/lib/postgresql",
  homedir
].each do |psql_dir|
  directory psql_dir do
    owner "postgres"
    group "postgres"
    mode "0700"
    recursive true
  end
end

%w{
  pg_hba.conf.ctmpl
  pg_ident.conf.ctmpl
  postgresql.conf.ctmpl
  postgresql-ha-master.json.ctmpl
  postgresql-ha-slave.json.ctmpl
  recovery.conf.ctmpl
}.each do |ctmpl|
  template "/var/app/postgresql/template/#{ctmpl}" do
    source ctmpl
    owner "postgres"
    group "postgres"
    mode "0444"
  end
end

sudo_rule "postgres-ha" do
  user "postgres"
  runas "ALL"
  command "NOPASSWD:/usr/bin/systemctl *"
end

template "/var/lib/postgresql/postgresql-ha" do
  source "postgresql-ha.sh"
  owner "postgres"
  group "postgres"
  mode "0544"

  notifies :restart, "service[postgresql-ha]", :delayed
end

%w{
  postgresql-ha-check-master.sh
  postgresql-ha-check-slave.sh
}.each do |check_file|
  template "/var/app/consul/shared/config/services/#{check_file}" do
    source check_file
    owner "consul"
    group "consul"
    mode "0544"

    notifies :reload, "service[consul]", :delayed
  end
end

systemd_tmpfiles "postgresql"
systemd_unit "postgresql@.service"

# postgresql must not auto-start, postgresql-ha will do that
service "postgresql" do
  service_name "postgresql@#{version}.service"
  action [:disable]
end

systemd_unit "postgresql-ha.service" do
  template true
end

service "postgresql-ha" do
  action [:enable, :start]
end
