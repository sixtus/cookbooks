tag("hadoop-jobtracker")

include_recipe "hadoop"

service "hadoop-jobtracker" do
  action [:enable, :start]
end

if tagged?("nagios-client")
  nrpe_command "check_hadoop_jobtracker" do
    command "/usr/lib/nagios/plugins/check_pidfile /var/run/hadoop/jobtracker.pid"
  end

  nagios_service "HADOOP-JOBTRACKER" do
    check_command "check_nrpe!check_hadoop_jobtracker"
  end
end
