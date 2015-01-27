if gentoo?
  homedir = "/var/app/smc"

  include_recipe "golang"

  deploy_skeleton "smc"

  systemd_unit "smc.service" do
    template "smc.service"
    variables({
      path: homedir,
      user: "smc",
      group: "smc",
    })
  end

  deploy_go_application "smc" do
    repository "https://github.com/remerge/smc"
    notifies :restart, "service[smc]"
  end

  devices = Hash[node[:filesystem].map do |device, opts|
    [opts[:mount], File.basename(device)] if opts[:uuid] && opts[:mount] && File.directory?(opts[:mount])
  end.compact]

  file "/var/app/smc/current/plugin.d/system.json" do
    content({
      Enabled: true,
      Devices: devices,
    }.to_json)
    owner "smc"
    group "smc"
    notifies :restart, "service[smc]"
  end

  service "smc" do
    action [:enable, :start]
  end
end
