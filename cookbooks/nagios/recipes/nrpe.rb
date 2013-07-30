case node[:platform]
when "gentoo"
  package "net-analyzer/nrpe" do
    action :upgrade
  end

  portage_package_keywords "net-analyzer/nagios-check_pidfile"

  package "net-analyzer/nagios-check_pidfile"

when "debian"
  package "nagios-nrpe-server"

  git "/usr/local/src/check_pidfile" do
    repo "https://github.com/hollow/check_pidfile"
    branch "master"
    action :sync
  end

  execute "check_pidfile-install" do
    command "autoreconf -i && ./configure --prefix=/usr && make install"
    cwd "/usr/local/src/check_pidfile"
    creates "/usr/lib/nagios/plugins/check_pidfile"
    subscribes :run, "git[/usr/local/src/check_pidfile]", :immediately
  end
end

include_recipe "nagios"

directory "/etc/nagios/nrpe.d" do
  owner "nagios"
  group "nagios"
  mode "0750"
end

template "/etc/nagios/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "nagios"
  group "nagios"
  mode "0640"
  notifies :restart, "service[nrpe]"
end

systemd_unit "nrpe.service"

service "nrpe" do
  action [:enable, :start]
  supports [:reload]
end
