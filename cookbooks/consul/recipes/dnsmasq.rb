include_recipe "consul"

deploy_skeleton "dnsmasq"

deploy_application "dnsmasq" do
  repository node[:consul][:dnsmasq][:repository]
  revision node[:consul][:dnsmasq][:version]

  before_symlink do
    execute "build dnsmasq" do
      command "make"
      cwd release_path
      group "dnsmasq"
      user "dnsmasq"
    end
  end

end

if systemd_running?
  systemd_unit "dnsmasq.service"

  service "dnsmasq" do
    action [:start, :enable]
    subscribes :restart, "deploy_application[dnsmasq]", :delayed
    subscribes :restart, "systemd_unit[dnsmasq]", :delayed
  end

  local_dns = %w{127.0.0.1 8.8.8.8 8.8.4.4}
  if node[:resolv][:nameservers] != local_dns
    node.set[:resolv][:nameservers] = local_dns
  end
end
