if platform?("mac_os_x")
  package "ssh-copy-id"
else
  package "net-misc/openssh"
end

unless solo?
  nodes = node.run_state[:nodes].select do |n|
    n[:keys] and n[:keys][:ssh]
  end

  template "/etc/ssh/ssh_known_hosts" do
    source "known_hosts"
    owner "root"
    group "root"
    mode "0644"
    variables :nodes => nodes
  end
end

if solo?
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
