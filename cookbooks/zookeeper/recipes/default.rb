include_recipe "java"

if gentoo?
  package "sys-cluster/zookeeper"

  template "/opt/zookeeper/bin/zkServer.sh" do
    source "zkServer.sh"
    owner "root"
    group "root"
    mode "0755"
    notifies :restart, "service[zookeeper]" unless mac_os_x?
  end

elsif mac_os_x?
  package "zookeeper"
end

template "#{node[:zookeeper][:confdir]}/log4j.properties" do
  source "log4j.properties"
  mode "0644"
  notifies :restart, "service[zookeeper]" unless mac_os_x?
end

include_recipe "base::run_state"

myid = zookeeper_nodes.index do |n|
  n[:fqdn] == node[:fqdn]
end + 1

template "#{node[:zookeeper][:confdir]}/zoo.cfg" do
  source "zoo.cfg"
  mode "0644"
  notifies :restart, "service[zookeeper]" unless mac_os_x?
end

directory node[:zookeeper][:datadir] do
  recursive true
end

file "#{node[:zookeeper][:datadir]}/myid" do
  content "#{myid}\n"
  mode "0644"
  notifies :restart, "service[zookeeper]" unless mac_os_x?
end

if gentoo?
  systemd_unit "zookeeper.service"

  service "zookeeper" do
    action [:enable, :start]
  end
end

cron "zk-log-clean" do
  minute "0"
  hour "3"
  command "/opt/zookeeper/bin/zkCleanup.sh /var/lib/zookeeper/ -n 5"
end

if nagios_client?
  nagios_plugin "check_zookeeper" do
    source "check_zookeeper.rb"
  end

  nrpe_command "check_zookeeper_status" do
    command "/usr/lib/nagios/plugins/check_zookeeper -m Status -H localhost"
  end

  nagios_service "ZOOKEEPER-STATUS" do
    check_command "check_nrpe!check_zookeeper_status"
    servicegroups "zookeeper"
  end

  nrpe_command "check_zookeeper_readonly" do
    command "/usr/lib/nagios/plugins/check_zookeeper -m ReadOnly -H localhost"
  end

  nagios_service "ZOOKEEPER-READONLY" do
    check_command "check_nrpe!check_zookeeper_readonly"
    servicegroups "zookeeper"
  end

  if zookeeper_nodes.count > 1
    nrpe_command "check_zookeeper_followers" do
      command "/usr/lib/nagios/plugins/check_zookeeper -m Followers -n #{zookeeper_nodes.map {|n| n[:fqdn]}.join(" -n ")}"
    end

    nagios_service "ZOOKEEPER-FOLLOWERS" do
      check_command "check_nrpe!check_zookeeper_followers"
    end
  end

  {
    :connections => [2000, 3000],
    :watches => [50000, 100000],
    :latency => [1000, 2000],
    :requests => [20, 50],
    :files => [2048, 4096],
  }.each do |mode, threshold|
    nrpe_command "check_zookeeper_#{mode}" do
      command "/usr/lib/nagios/plugins/check_zookeeper -m #{mode.capitalize} -H localhost -w #{threshold[0]} -c #{threshold[1]}"
    end

    nagios_service "ZOOKEEPER-#{mode.to_s.upcase}" do
      check_command "check_nrpe!check_zookeeper_#{mode}"
      servicegroups "zookeeper"
    end
  end
end
