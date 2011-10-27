include_recipe "ssh"

package "dev-vcs/gitosis"

execute "gitosis-init" do
  command "sudo -H -u git gitosis-init < /root/.ssh/id_rsa.pub"
  creates "/var/spool/gitosis/.gitosis.conf"
end

template "/etc/conf.d/git-daemon" do
  source "git-daemon.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[git-daemon]"
end

service "git-daemon" do
  action [:start, :enable]
end
