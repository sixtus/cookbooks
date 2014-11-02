include_recipe "aerospike"

directory "/var/run/aerospike" do
  owner "root"
  group "root"
  mode "0644"
end

directory "/var/log/aerospike" do
  owner "root"
  group "root"
  mode "0644"
end

systemd_unit "xdr.service" do
  template true
end

service "xdr" do
  action [:enable, :start]
end

cookbook_file "/etc/logrotate.d/xdr" do
  source "logrotate.conf"
  owner "root"
  group "root"
  mode "0644"
end

nrpe_command "check_aerospike_xdr_lastship" do
  command "/usr/lib/nagios/plugins/check_aerospike -p 4004 -s timediff_lastship_cur_secs -w 1 -c 2"
end

nagios_service "AEROSPIKE-XDR-LASTSHIP" do
  check_command "check_nrpe!check_aerospike_xdr_lastship"
  servicegroups "aerospike"
end

nrpe_command "check_aerospike_xdr_outstanding" do
  command "/usr/lib/nagios/plugins/check_aerospike -p 4004 -s stat_recs_outstanding -w 500 -c 1000"
end

nagios_service "AEROSPIKE-XDR-OUTSTANDING" do
  check_command "check_nrpe!check_aerospike_xdr_outstanding"
  servicegroups "aerospike"
end

nrpe_command "check_aerospike_xdr_unknown_ns" do
  command "/usr/lib/nagios/plugins/check_aerospike -p 4004 -s noship_recs_unknown_namespace -w 1 -c 1"
end

nagios_service "AEROSPIKE-XDR-UNKNOWN-NS" do
  check_command "check_nrpe!check_aerospike_xdr_unknown_ns"
  servicegroups "aerospike"
end

nrpe_command "check_aerospike_xdr_dropped" do
  command "/usr/lib/nagios/plugins/check_aerospike -p 4004 -s stat_recs_dropped -w 1 -c 1"
end

nagios_service "AEROSPIKE-XDR-DROPPED" do
  check_command "check_nrpe!check_aerospike_xdr_dropped"
  servicegroups "aerospike"
end
