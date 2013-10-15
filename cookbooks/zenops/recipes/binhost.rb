clients = node.run_state[:nodes].select do |n|
  n[:primary_ipaddress] and
  n[:platform] == "gentoo" and
  n[:portage][:repo] == "zentoo"
end.map do |n|
  n[:primary_ipaddress]
end

template "/usr/sbin/pkgsync" do
  source "pkgsync.sh"
  owner "root"
  group "root"
  mode "0755"
  variables :clients => clients
end

systemd_unit "pkgsync.service"

systemd_timer "pkgsync" do
  schedule "OnCalendar=*:25"
end
