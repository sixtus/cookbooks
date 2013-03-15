include_recipe "ssh"

node.set[:ssh][:server][:matches] = {}

template "/etc/ssh/sshd_config" do
  source "sshd_config"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[sshd]"
end

systemd_unit "sshd.service"

service "sshd" do
  action [:enable, :start]
end

execute "root-ssh-key" do
  command "ssh-keygen -f /root/.ssh/id_rsa -N '' -C root@#{node[:fqdn]}"
  creates "/root/.ssh/id_rsa"
end

package "app-admin/denyhosts"

cookbook_file "/etc/denyhosts.conf" do
  source "denyhosts.conf"
  owner "root"
  group "root"
  mode "0640"
end

allowed_hosts = node.run_state[:nodes].select do |n|
  n[:primary_ipaddress]
end.map do |n|
  n[:primary_ipaddress]
end + node[:denyhosts][:whitelist]

file "/var/lib/denyhosts/allowed-hosts" do
  content allowed_hosts.sort.join("\n")
  owner "root"
  group "root"
  mode "0644"
end

# Need this during bootstrap when syslog-ng has not created the file, but
# denyhosts fails if it does not exist. d'oh
file "/var/log/auth.log" do
  owner "root"
  group "wheel"
  mode "0640"
end

service "denyhosts" do
  action [:disable, :stop]
end

cron "denyhosts" do
  minute "*/10"
  command "/usr/bin/denyhosts.py -c /etc/denyhosts.conf"
end

cookbook_file "/etc/logrotate.d/denyhosts" do
  source "denyhosts.logrotate"
  owner "root"
  group "root"
  mode "0644"
end

if tagged?("nagios-client")
  nagios_service "SSH" do
    check_command "check_ssh!22"
    servicegroups "system"
    env [:testing, :development]
  end
end
