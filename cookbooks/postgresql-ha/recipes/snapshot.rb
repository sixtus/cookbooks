include_recipe "postgresql"

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

systemd_timer "postgresql-snapshot" do
  schedule %w(OnCalendar=hourly)
  unit({
    command: [
      "/var/app/postgresql/postgres-snapshot"
    ],
    user: "postgres",
    group: "postgres",
  })
end
