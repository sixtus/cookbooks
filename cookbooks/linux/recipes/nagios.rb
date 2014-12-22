if nagios_client?
  include_recipe "nagios::client"

  nrpe_command "check_load" do
    command "/usr/lib/nagios/plugins/check_load -w #{node[:cpu][:total]*3} -c #{node[:cpu][:total]*10}"
  end

  nagios_service "LOAD" do
    check_command "check_nrpe!check_load"
    servicegroups "system"
    env [:staging, :testing, :development]
  end

  nrpe_command "check_zombie_procs" do
    command "/usr/lib/nagios/plugins/check_procs -w 5 -c 10 -s Z"
  end

  nagios_service "ZOMBIES" do
    check_command "check_nrpe!check_zombie_procs"
    servicegroups "system"
    env [:staging, :testing, :development]
  end

  containers = %x(lxc-ls).chomp.split.length rescue 0
  procs_max = 1024 * (containers + 1)

  nrpe_command "check_total_procs" do
    command "/usr/lib/nagios/plugins/check_procs -w #{procs_max/2} -c #{procs_max}"
  end

  nagios_service "PROCS" do
    check_command "check_nrpe!check_total_procs"
    servicegroups "system"
    env [:staging]
  end

  nagios_plugin "check_open_files"

  nrpe_command "check_open_files" do
    command "/usr/lib/nagios/plugins/check_open_files -w 75 -c 90"
  end

  nagios_service "OPEN-FILES" do
    check_command "check_nrpe!check_open_files"
    servicegroups "system"
    env [:staging, :testing, :development]
  end

  nagios_plugin "check_mem"

  nrpe_command "check_mem" do
    if node[:memory][:total].to_i > 16*1024*1024
      command "/usr/lib/nagios/plugins/check_mem -C -u -w 95 -c 99"
    else
      command "/usr/lib/nagios/plugins/check_mem -C -u -w 80 -c 95"
    end
  end

  nagios_service "MEMORY" do
    check_command "check_nrpe!check_mem"
    servicegroups "system"
    env [:staging, :testing, :development]
  end

  nagios_plugin "check_raid"

  nrpe_command "check_raid" do
    command "/usr/lib/nagios/plugins/check_raid"
  end

  nagios_service "RAID" do
    check_command "check_nrpe!check_raid"
    servicegroups "system"
    env [:staging, :testing, :development]
  end

  mounts = node[:filesystem].values.map do |fs|
    next if fs[:mount] =~ %r{/run/user/}
    next if fs[:mount] =~ %r{/lxc}
    fs if fs[:fs_type] && fs[:mount] && File.directory?(fs[:mount])
  end.compact.map do |fs|
    warn = [fs[:kb_size].to_i * 0.10, 1.0 * 1024 * 1024].min.to_i / 1024
    crit = [fs[:kb_size].to_i * 0.05, 0.5 * 1024 * 1024].min.to_i / 1024
    warn > 0 && crit > 0 ? "-w #{warn} -c #{crit} -p #{fs[:mount]}" : nil
  end.compact.join(' -C ')

  nrpe_command "check_disks" do
    command "/usr/lib/nagios/plugins/check_disk #{mounts}"
  end

  nagios_service "DISKS" do
    check_command "check_nrpe!check_disks"
    notification_interval 15
    servicegroups "system"
    env [:staging, :testing, :development]
  end

  nrpe_command "check_swap" do
    command "/usr/lib/nagios/plugins/check_swap -w 75% -c 50%"
  end

  nagios_service "SWAP" do
    check_command "check_nrpe!check_swap"
    notification_interval 180
    servicegroups "system"
    env [:staging, :testing, :development]
  end

  sudo_rule "nagios-ethtool" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /usr/sbin/ethtool"
    command "NOPASSWD: /sbin/ethtool" if debian_based?
  end

  nagios_plugin "check_link_usage"

  nrpe_command "check_link_usage" do
    command "/usr/lib/nagios/plugins/check_link_usage"
  end

  nagios_service "LINK" do
    check_command "check_nrpe!check_link_usage"
    servicegroups "network"
    check_interval 10
    env [:staging, :testing, :development]
  end

  nrpe_command "check_time" do
    command "/usr/lib/nagios/plugins/check_ntp_time -H pool.ntp.org -w 0.5 -c 1"
  end

  nagios_service "TIME" do
    check_command "check_nrpe!check_time"
    servicegroups "system"
    env [:testing, :development]
  end
end
