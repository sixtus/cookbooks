action :create do
  nr = new_resource

  systemd_unit "#{nr.service}.timer" do
    template "timer.unit"
    cookbook "systemd"
    variables service: nr.service, schedule: nr.schedule
  end

  service "#{nr.service}.timer" do
    action [:enable, :start]
    only_if { systemd_running? }
  end
end

action :delete do
  nr = new_resource

  service "#{nr.service}.timer" do
    action [:disable, :stop]
    only_if { systemd_running? }
  end

  systemd_unit "#{nr.service}.timer" do
    action :delete
  end
end
