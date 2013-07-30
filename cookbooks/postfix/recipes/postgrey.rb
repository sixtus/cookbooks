package "mail-filter/postgrey"

systemd_unit "postgrey.service"

service "postgrey" do
  action [:enable, :start]
end
