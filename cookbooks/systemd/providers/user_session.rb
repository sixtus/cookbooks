include ChefUtils::Account

action :enable do
  user = get_user(new_resource.name)

  directory "#{user[:dir]}/.config/systemd/user" do
    owner user[:name]
    group user[:group][:name]
    mode "0755"
    recursive true
  end

  service "user-session@#{user[:name]}" do
    action [:enable, :start]
    only_if { systemd_running? }
  end

  execute "systemd-reload-#{user[:name]}" do
    command "systemctl --user daemon-reload"
    user user[:name]
    group user[:group][:name]
    action :nothing
    only_if { systemd_running? }
  end
end

action :disable do
  user = get_user(new_resource.name)

  service "user-session@#{user[:name]}" do
    action [:disable, :stop]
    only_if { systemd_running? }
  end
end
