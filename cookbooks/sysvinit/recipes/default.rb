if node[:virtualization][:role] == "guest" and node[:virtualization][:system] == "linux-vserver"
  execute "init-reload" do
    command "/bin/true"
    action :nothing
  end
else
  execute "init-reload" do
    command "/sbin/telinit q"
    action :nothing
  end
end

template "/etc/inittab" do
  source "inittab"
  owner "root"
  group "root"
  mode "0644"
  notifies :run, "execute[init-reload]"
  backup 0
end
