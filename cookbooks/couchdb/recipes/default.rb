package "dev-db/couchdb"

directory "/var/lib/couchdb" do
  owner "couchdb"
  group "root"
  mode "0755"
end

directory "/var/run/couchdb" do
  owner "couchdb"
  group "couchdb"
  mode "0755"
end

directory "/var/log/couchdb" do
  owner "couchdb"
  group "couchdb"
  mode "0750"
end

service "epmd" do
  action [:enable, :start]
end

service "couchdb" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_couchdb" do
    command "/usr/lib/nagios/plugins/check_http -H localhost -p 5984 -s couchdb"
  end

  nagios_service "COUCHDB" do
    check_command "check_nrpe!check_couchdb"
  end
end
