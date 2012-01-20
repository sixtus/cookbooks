template "/etc/hosts" do
  owner "root"
  group "root"
  mode "0644"
  source "hosts"
  variables :nodes => node.run_state[:nodes]
end

unless platform?("mac_os_x")
  template "/etc/resolv.conf" do
    owner "root"
    group "root"
    mode "0644"
    source "resolv.conf"
  end
end
