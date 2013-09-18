portage_package_use "net-ftp/pure-ftpd" do
  use %w(vchroot) + node[:pureftpd][:use_flags]
end

package "net-ftp/pure-ftpd"

file "/etc/pureftpd.passwd" do
  owner "root"
  group "root"
  mode "0600"
end

execute "pure-pw-mkdb" do
  command "pure-pw mkdb /etc/pureftpd.pdb -f /etc/pureftpd.passwd"
  not_if { FileUtils.uptodate?("/etc/pureftpd.pdb", %w(/etc/pureftpd.passwd)) }
end

systemd_unit "pure-ftpd.service" do
  template true
end

service "pure-ftpd" do
  action [:enable, :start]
end

shorewall_rule "pure-ftpd" do
  destport "21,32768:61000"
end

shorewall6_rule "pure-ftpd" do
  destport "21,32768:61000"
end
