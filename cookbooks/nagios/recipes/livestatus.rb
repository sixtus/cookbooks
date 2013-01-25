include_recipe "xinetd"

package "net-analyzer/mk-livestatus"

cookbook_file "/etc/xinetd.d/livestatus" do
  source "xinetd.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[xinetd]"
end
