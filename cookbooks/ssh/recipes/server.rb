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

if tagged?("nagios-client")
  nagios_service "SSH" do
    check_command "check_ssh!22"
    servicegroups "system"
    env [:testing, :development]
  end
end
