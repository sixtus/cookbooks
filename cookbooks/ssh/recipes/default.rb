case node[:platform]
when "gentoo"
  if root?
    package "net-misc/openssh"
  end

when "mac_os_x"
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

if solo? and not root?
  directory File.dirname(node[:ssh][:config]) do
    mode "0700"
  end
else
  directory File.dirname(node[:ssh][:config]) do
    mode "0755"
  end
end

if solo? and not root?
  overridable_template node[:ssh][:config] do
    source "ssh_config"
    mode "0600"
    namespace :user
    instance node[:current_user]
  end
else
  template node[:ssh][:config] do
    source "ssh_config"
    mode "0644"
  end
end
