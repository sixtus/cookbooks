include_recipe "metro"
include_recipe "zenops::mirror-zentoo"

file "/usr/sbin/pkgsync" do
  action :delete
end

systemd_timer "pkgsync" do
  action :delete
end
