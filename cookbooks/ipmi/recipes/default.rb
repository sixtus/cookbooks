if gentoo?
  package "sys-apps/ipmitool"
  package "sys-libs/freeipmi"
elsif debian_based?
  package "ipmitool"
  package "freeipmi-tools"
end

if nagios_client? && !lxc?
  ipmi_exclude = "--exclude-sensor-types=#{node[:ipmi][:exclude_sensor_types].join(',')}"

  sudo_rule "nagios-ipmi-sensors" do
    user "nagios"
    runas "root"
    command "NOPASSWD: /usr/sbin/ipmi-sensors #{ipmi_exclude} --quiet-cache --sdr-cache-recreate --interpret-oem-data --output-sensor-state --ignore-not-available-sensors"
  end

  package "net-analyzer/nagios-check_ipmi_sensor"

  nrpe_command "check_ipmi_sensor" do
    command "/usr/lib/nagios/plugins/check_ipmi_sensor -H localhost -O #{ipmi_exclude}"
  end

  nagios_service "IPMI-SENSOR" do
    check_command "check_nrpe!check_ipmi_sensor"
    servicegroups "system"
    env [:staging, :testing, :development]
  end
end
