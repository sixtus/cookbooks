tag("pkgsync-client")

master = node.run_state[:nodes].select do |n|
  n[:tags].include?("pkgsync-master")
end.first

if master
  file "/etc/rsyncd.secrets" do
    content "pkgsync:#{master[:pkgsync][:password]}\n"
    owner "root"
    group "root"
    mode "0600"
  end

  template "/etc/rsyncd.conf" do
    source "rsyncd.conf"
    owner "root"
    group "root"
    mode "0640"
    variables :allow => master[:ipaddress]
    notifies :restart, "service[rsyncd]"
  end

  service "rsyncd" do
    action [:enable, :start]
  end
end
