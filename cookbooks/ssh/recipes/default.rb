if gentoo?
  package "net-misc/openssh"

elsif debian_based?
  package "openssh-client"
  package "openssh-server"

elsif mac_os_x?
  package "ssh-copy-id"

end

if root?
  nodes = node.run_state[:nodes].select do |n|
    n[:keys] and n[:keys][:ssh]
  end

  template node[:ssh][:hostsfile] do
    source "known_hosts"
    owner "root"
    group "root"
    mode "0644"
    variables :nodes => nodes
  end
end

directory File.dirname(node[:ssh][:config]) do
  mode(root? ? "0755" : "0700")
end

if root?
  template node[:ssh][:config] do
    source "ssh_config"
    mode "0644"
  end
else
  overridable_template node[:ssh][:config] do
    source "ssh_config"
    mode "0600"
    namespace :user
    instance node[:current_user]
  end
end
