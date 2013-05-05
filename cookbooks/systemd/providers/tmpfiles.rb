action :create do
  directory "/etc/tmpfiles.d-#{rrand}" do
    path "/etc/tmpfiles.d"
    owner "root"
    group "root"
    mode "0755"
  end

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
