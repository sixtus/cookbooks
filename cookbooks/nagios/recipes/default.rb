directory "/etc/nagios" do
  owner "nagios"
  group "nagios"
  mode "0750"
end

directory "/var/run/nsca" do
  owner "nagios"
  group "nagios"
  mode "0755"
end
