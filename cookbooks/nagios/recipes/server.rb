include_recipe "nginx"

portage_package_use "net-analyzer/nagios-plugins" do
  use %w(ldap mysql nagios-dns nagios-ntp nagios-ping nagios-ssh postgres)
end

package "net-analyzer/nagios"

include_recipe "nagios"
include_recipe "nagios::nrpe"
include_recipe "nagios::nsca"

package "net-analyzer/mk-livestatus"

directory "/var/nagios/rw" do
  owner "nagios"
  group "nginx"
  mode "6755"
end

file "/var/nagios/rw/nagios.cmd" do
  owner "nagios"
  group "nginx"
  mode "0660"
  action :create_if_missing # prevent chef from building a checksum on a FIFO
  only_if { File.exist?("/var/nagios/rw/nagios.cmd") } # do not create the FIFO ourselves
end

template "/usr/lib/nagios/plugins/notify" do
  source "notify.#{node[:nagios][:notifier]}"
  owner "root"
  group "nagios"
  mode "0750"
end

nagios_plugin "check_aggregate"

# retrieve data from the search index
contacts = node.users.select do |u|
  u[:tags] and not (u[:tags] & ["hostmaster", "nagios"]).empty?
end.sort_by do |u|
  u[:id]
end

hostmasters = contacts.select do |c|
  c[:tags] and c[:tags].include?("hostmaster")
end.map do |c|
  c[:id]
end

hosts = nagios_client_nodes

# super ugly virtual host support for nagios
def add_services_for_vhost(vhost)
  nagios_client_nodes.each do |n|
    next if !n[:nagios] or !n[:nagios][:services]
    n[:nagios][:services].each do |name, params|
      vhost.default[:nagios][:services][name] = params if params[:host_name] == vhost[:fqdn]
    end
  end
end

vhosts = hosts.map do |h|
  h[:nagios][:vhosts] rescue []
end.flatten.compact.sort.uniq.map do |vhost|
  Chef::Node.new.tap do |n|
    n.chef_environment "production"
    n.default[:fqdn] = vhost
    n.default[:ipaddress] = vhost
    n.default[:virtualization] = {}
    n.default[:nagios][:services] = {}
    add_services_for_vhost(n)
  end
end

hosts = (vhosts + hosts.to_a).sort_by do |n|
  n[:fqdn]
end

# build hostgroups
hostgroups = Hash.new do |hsh, key|
  hsh[key] = []
end

hosts.each do |h|
  # group per cluster
  cluster = h.cluster_domain
  hostgroups[cluster] << h[:fqdn] if !cluster.nil?

  # group per role
  (h[:roles] || []).each do |r|
    next if r == 'base'
    next if r == h.cluster_name
    hostgroups[r] << h[:fqdn]
  end
end

# remove sample objects
%w(hosts localhost printer services switch windows).each do |f|
  file "/etc/nagios/objects/#{f}.cfg" do
    action :delete
  end
end

# nagios base config
%w(nagios nsca resource).each do |f|
  nagios_conf f do
    subdir false
  end
end

nagios_conf "cgi" do
  subdir false
  variables :hostmasters => hostmasters
end

# create nagios objects
nagios_conf "commands"
nagios_conf "contacts"
nagios_conf "templates"
nagios_conf "timeperiods"

nagios_conf "hostgroups" do
  variables hostgroups: hostgroups
end

nagios_conf "servicegroups" do
  variables hosts: hosts
end

hosts.each do |host|
  next if host[:fqdn].empty?
  nagios_conf "host-#{host[:fqdn]}" do
    template "host.cfg.erb"
    variables :host => host
  end
end

ruby_block "cleanup-nagios" do
  block do
    Dir["/etc/nagios/objects/host-*.cfg"].each do |f|
      fqdn = File.basename(f, ".cfg").sub(/host-/, '')
      next if hosts.any? { |h| h[:fqdn] == fqdn }
      File.unlink(f)
    end
  end
  only_if do
    Dir["/etc/nagios/objects/host-*.cfg"].select do |f|
      fqdn = File.basename(f, ".cfg").sub(/host-/, '')
      !hosts.any? { |h| h[:fqdn] == fqdn }
    end.any?
  end
  notifies :restart, "service[nagios]"
end

include_recipe "nagios::extras"

systemd_unit "nagios.service"

service "nagios" do
  action [:enable, :start]
  supports [:reload]
end

service "nsca" do
  action [:disable, :stop]
end

# Web UI
group "nagios" do
  members %w(nginx)
  append true
end

file "/etc/nagios/users" do
  content contacts.map { |c| "#{c[:id]}:#{c[:password]}" }.join("\n")
  owner "root"
  group "nginx"
  mode "0640"
end

spawn_fcgi "nagios" do
  user "nagios"
  group "nagios"
  program "/usr/sbin/fcgiwrap"
  socket({
    :user => "nginx",
    :group => "nginx",
  })
end

include_recipe "nginx"

ssl_certificate "/etc/ssl/nginx/nagios" do
  cn node[:nagios][:certificate]
end

nginx_server "nagios" do
  template "nginx.conf"
end

shorewall_rule "nagios" do
  destport "80,443"
end

file "/var/www/localhost/htdocs/index.php" do
  action :delete
end

file "/var/www/localhost/htdocs/index.html" do
  action :delete
end

template "/usr/share/nagios/htdocs/index.html" do
  source "index.html"
  owner "nagios"
  group "nagios"
  mode "0644"
end

cookbook_file "/usr/share/nagios/htdocs/side.html" do
  source "side.html"
  owner "nagios"
  group "nagios"
  mode "0644"
end

# nagios health check
nrpe_command "check_nagios" do
  command "/usr/lib/nagios/plugins/check_nagios -F /var/nagios/status.dat -C /usr/sbin/nagios -e 5"
end

nagios_service "NAGIOS" do
  check_command "check_nrpe!check_nagios"
end
