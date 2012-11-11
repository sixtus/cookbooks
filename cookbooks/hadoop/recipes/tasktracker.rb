include_recipe "hadoop::default"

service "hadoop-tasktracker" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_hadoop_tasktracker" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/hadoop/tasktracker.pid"
  end

  nagios_service "HADOOP-TASKTRACKER" do
    check_command "check_nrpe!check_hadoop_tasktracker"
  end
end
