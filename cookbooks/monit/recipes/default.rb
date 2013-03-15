package "app-admin/monit"

file "/etc/init.d/monit" do
  action :delete
end

directory "/etc/monit.d" do
  action :delete
  recursive true
end

file "/etc/monitrc" do
  action :delete
end
