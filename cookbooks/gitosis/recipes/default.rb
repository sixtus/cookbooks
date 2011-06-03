include_recipe "ssh"

package "dev-vcs/gitosis"

execute "gitosis-init" do
  command "sudo -H -u git gitosis-init < /root/.ssh/id_rsa.pub"
  creates "/var/spool/gitosis/.gitosis.conf"
end
