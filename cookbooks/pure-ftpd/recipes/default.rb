portage_package_use "net-ftp/pure-ftpd" do
  use %w(vchroot) + node[:pureftpd][:use_flags]
end

package "net-ftp/pure-ftpd"

template "/etc/conf.d/pure-ftpd" do
  source "pure-ftpd.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[pure-ftpd]"
end

file "/etc/pureftpd.passwd" do
  owner "root"
  group "root"
  mode "0600"
end

execute "pure-pw-mkdb" do
  command "pure-pw mkdb /etc/pureftpd.pdb -f /etc/pureftpd.passwd"
  not_if { FileUtils.uptodate?("/etc/pureftpd.pdb", %w(/etc/pureftpd.passwd)) }
end

systemd_unit "pure-ftpd.service"

service "pure-ftpd" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_pureftpd" do
    command "/usr/lib/nagios/plugins/check_systemd pure-ftpd.service /run/pure-ftpd.pid"
  end

  nagios_service "PURE-FTPD" do
    check_command "check_nrpe!check_pureftpd"
  end
end
