include_recipe "aerospike"

template "/etc/aerospike/aerospike.conf" do
  source "aerospike.conf"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[aerospike]"
end

systemd_unit "aerospike.service" do
  template true
end

service "aerospike" do
  action [:enable, :start]
end

backupdir = "/var/lib/aerospike/backup"

directory backupdir do
  owner "root"
  group "root"
  mode "0755"
end

if aerospike_nodes.first
  primary = (node[:fqdn] == aerospike_nodes.first[:fqdn])
else
  primary = true
end

primary = false unless File.exist?("/usr/bin/asbackup")

systemd_timer "aerospike-backup" do
  schedule %w(OnCalendar=daily)
  unit({
    command: [
      "/bin/bash -c 'rm -rf #{backupdir}/*'",
      "/usr/bin/asbackup -p 4000 -n data -d #{backupdir}",
    ],
    user: "root",
    group: "root",
  })
  action :delete unless primary
end

duply_backup "aerospike" do
  source backupdir
  max_full_backups 30
  incremental false
  action :delete unless primary
end

nrpe_command "check_aerospike_cluster_size" do
  command "/usr/lib/nagios/plugins/check_aerospike -p 4000 -s cluster_size -w #{aerospike_nodes.length} -c #{aerospike_node.length}"
end

nagios_service "AEROSPIKE-CLUSTER-SIZE" do
  check_command "check_nrpe!check_aerospike_cluster_size"
  servicegroups "aerospike"
end

nrpe_command "check_aerospike_waiting_tx" do
  command "/usr/lib/nagios/plugins/check_aerospike -p 4000 -s waiting_transactions -w 1 -c 1"
end

nagios_service "AEROSPIKE-WAITING-TX" do
  check_command "check_nrpe!check_aerospike_waiting_tx"
  servicegroups "aerospike"
end

node[:aerospike][:namespaces].each do |ns, config|
  if config[:storage_engine].is_a?(Hash)
    nrpe_command "check_aerospike_#{ns}_available" do
      command "/usr/lib/nagios/plugins/check_aerospike -p 4000 -n #{ns} -s available_pct -w 20 -c 15"
    end

    nagios_service "AEROSPIKE-#{ns.upcase}-AVAILABLE" do
      check_command "check_nrpe!check_aerospike_#{ns}_available"
      servicegroups "aerospike"
    end

    nrpe_command "check_aerospike_#{ns}_free_disk" do
      command "/usr/lib/nagios/plugins/check_aerospike -p 4000 -n #{ns} -s free-pct-disk -w 20 -c 15"
    end

    nagios_service "AEROSPIKE-#{ns.upcase}-FREE-DISK" do
      check_command "check_nrpe!check_aerospike_#{ns}_free_disk"
      servicegroups "aerospike"
    end
  end

  nrpe_command "check_aerospike_#{ns}_free_mem" do
    command "/usr/lib/nagios/plugins/check_aerospike -p 4000 -n #{ns} -s free-pct-memory -w 20 -c 15"
  end

  nagios_service "AEROSPIKE-#{ns.upcase}-FREE-MEM" do
    check_command "check_nrpe!check_aerospike_#{ns}_free_mem"
    servicegroups "aerospike"
  end

  nrpe_command "check_aerospike_#{ns}_hwm_breached" do
    command "/usr/lib/nagios/plugins/check_aerospike -p 4000 -n #{ns} -s hwm-breached -w 0 -c 0"
  end

  nagios_service "AEROSPIKE-#{ns.upcase}-HWM-BREACHED" do
    check_command "check_nrpe!check_aerospike_#{ns}_hwm_breached"
    servicegroups "aerospike"
  end

  nrpe_command "check_aerospike_#{ns}_stop_writes" do
    command "/usr/lib/nagios/plugins/check_aerospike -p 4000 -n #{ns} -s stop-writes -w 0 -c 0"
  end

  nagios_service "AEROSPIKE-#{ns.upcase}-STOP-WRITES" do
    check_command "check_nrpe!check_aerospike_#{ns}_stop_writes"
    servicegroups "aerospike"
  end
end
