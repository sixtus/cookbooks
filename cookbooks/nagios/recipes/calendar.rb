gem_package "google-api-client"

template "/usr/lib/nagios/plugins/check_calendar" do
  source "check_calendar.rb"
  owner "root"
  group "nagios"
  mode "0750"
end

nrpe_command "check_calendar" do
  command "/usr/lib/nagios/plugins/check_calendar"
end

nagios_service "WHOS-ON-CALL" do
  check_command "check_nrpe!check_calendar"
end
