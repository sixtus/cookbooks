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

package "dev-ruby/madvertise-logging"

cookbook_file "/usr/libexec/zendnspipe" do
  source "zendnspipe.rb"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart, "service[pdns]"
end

service "pdns" do
  action [:enable, :start]
end

if tagged?('ganymed-client')
  ganymed_collector 'zendns' do
    source 'zendns.rb'
  end
end
