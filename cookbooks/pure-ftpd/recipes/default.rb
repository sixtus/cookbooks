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

service "pure-ftpd" do
  action [:enable, :start]
end
