package "net-dns/c-ares"
package "dev-libs/libevent"

tar_url = "http://pgbouncer.github.io/downloads/files/#{node[:postgresql][:ha][:pgbouncer]}/pgbouncer-#{node[:postgresql][:ha][:pgbouncer]}.tar.gz"
binary = "/var/app/pgbouncer/releases/pgbouncer-#{node[:postgresql][:ha][:pgbouncer]}/pgbouncer"
release_dir = File.dirname(binary)
basename = File.basename(tar_url)

deploy_skeleton "pgbouncer"

tar_extract tar_url do
  target_dir "/var/app/pgbouncer/releases"
  user "pgbouncer"
  group "pgbouncer"

  not_if do
    File.exists?(binary)
  end
end

execute "pgbouncer-build" do
  not_if do
    File.exists?(binary)
  end

  command "/bin/bash -l -c './configure && make'"
  cwd release_dir
  user "pgbouncer"
  group "pgbouncer"
end

link "/var/app/pgbouncer/current" do
  to release_dir
  notifies :restart, "service[pgbouncer]", :delayed
end

template "/var/app/pgbouncer/shared/config/pgbouncer.ini" do
  source "pgbouncer.ini"
  owner "pgbouncer"
  group "pgbouncer"
  mode "0444"

  notifies :reload, "service[pgbouncer]", :delayed
end

systemd_unit "pgbouncer.service"

service "pgbouncer" do
  action [:enable, :start]
end
