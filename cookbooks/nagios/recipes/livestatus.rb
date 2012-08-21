package "net-analyzer/mk-livestatus"
package "sys-apps/xinetd"

cookbook_file "/etc/xinetd.d/livestatus" do
  source "xinetd.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[xinetd]"
end

service "xinetd" do
  action [:enable, :start]
end
