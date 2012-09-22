node.set[:mongodb][:replication][:set] = "zendns"
node.set[:mongodb][:bind_ip] = "0.0.0.0"

include_recipe "mongodb::server"

package "net-dns/pdns"

template "/etc/powerdns/pdns.conf" do
  source "pdns.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[pdns]"
end

package "dev-libs/mongo"

cookbook_file "/usr/src/zendnspipe.c" do
  source "zendnspipe.c"
  owner "root"
  group "root"
  mode "0644"
end

execute "compile-zendnspipe" do
  command "gcc -std=c99 -lmongoc -o /usr/libexec/zendnspipe /usr/src/zendnspipe.c"
  not_if { FileUtils.uptodate?("/usr/libexec/zendnspipe", ["/usr/src/zendnspipe.c"]) }
  notifies :restart, "service[pdns]"
end

service "pdns" do
  action [:enable, :start]
end
