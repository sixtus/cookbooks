include_recipe "ssh"

package "dev-vcs/gitolite"

execute "gitolite-key" do
  command "cp /root/.ssh/id_rsa.pub /var/lib/gitolite/root.pub"
  creates "/var/lib/gitolite/root.pub"
end

template "/var/lib/gitolite/.gitolite.rc" do
  source "gitolite.rc"
  owner "git"
  group "git"
  mode "0644"
end

execute "gitolite-init" do
  command "gl-setup /var/lib/gitolite/root.pub"
  creates "/var/lib/gitolite/repositories/gitolite-admin.git"
  environment ({'HOME' => "/var/lib/gitolite"})
  user "git"
  group "git"
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
