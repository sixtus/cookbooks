action :create do
  cookbook_file "/etc/tmpfiles.d/#{new_resource.name}.conf" do
    source "#{new_resource.name}.tmpfiles"
    owner "root"
    group "root"
    mode "0644"
    notifies :run, "execute[systemd-tmpfiles]", :immediately
  end
end

action :delete do
  file "/etc/tmpfiles.d/#{new_resource.name}.conf" do
    action :delete
  end
end
