include_recipe "ssh"

package "dev-vcs/gitosis"

execute "gitosis-init" do
  command "sudo -H -u git gitosis-init < /root/.ssh/id_rsa.pub"
  creates "/var/spool/gitosis/.gitosis.conf"
end

cookbook_file "/usr/bin/git-init-bare-empty" do
  source "git-init-bare-empty.sh"
  owner "root"
  group "root"
  mode "0755"
end
