package "dev-lang/erlang"

systemd_unit "epmd.service"

service "epmd" do
  action [:enable, :start]
end
