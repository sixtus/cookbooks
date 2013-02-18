action :create do
  if systemd?
    cookbook_file "/etc/tmpfiles.d/#{new_resource.name}.conf" do
      source "#{new_resource.name}.tmpfiles"
      owner "root"
      group "root"
      mode "0644"
      notifies :run, "execute[systemd-tmpfiles]", :immediately
    end
  end
end

action :delete do
  if systemd?
    file "/etc/tmpfiles.d/#{new_resource.name}.conf" do
      action :delete
    end
  end
end
