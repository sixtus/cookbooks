action :create do
  path = "/usr/lib/systemd/system/#{new_resource.name}"

  if systemd?
    cookbook_file path do
      source new_resource.name
      owner "root"
      group "root"
      mode "0644"
      notifies :run, "execute[systemd-reload]", :immediately
    end
  end
end

action :delete do
  path = "/usr/lib/systemd/system/#{new_resource.name}"

  if systemd?
    cookbook_file path do
      action :delete
      notifies :run, "execute[systemd-reload]", :immediately
    end
  end
end
