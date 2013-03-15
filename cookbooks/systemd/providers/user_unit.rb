action :create do
  user = get_user(new_resource.user)
  path = "#{user[:dir]}/.config/systemd/user/#{new_resource.name}"

  cookbook_file path do
    source new_resource.name
    owner "root"
    group "root"
    mode "0644"
    notifies :run, "execute[systemd-reload-#{user[:name]}]", :immediately
  end
end

action :delete do
  user = get_user(new_resource.user)
  path = "#{user[:dir]}/.config/systemd/user/#{new_resource.name}"

  cookbook_file path do
    action :delete
    notifies :run, "execute[systemd-reload-#{user[:name]}]", :immediately
  end
end
