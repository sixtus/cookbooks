if gentoo?
  package "app-misc/beanstalkd"
elsif mac_os_x?
  package "beanstalk"
end

systemd_unit "beanstalkd.service"

service "beanstalkd" do
  action [:enable, :start]
end

# nagios
if nagios_client?
  package "dev-python/beanstalkc"

  nagios_plugin "check_beanstalkd"

  nrpe_command "check_beanstalkd" do
    command "/usr/lib/nagios/plugins/check_beanstalkd -S localhost:11300 " +
            "-w #{node[:beanstalkd][:nagios][:warning]} " +
            "-c #{node[:beanstalkd][:nagios][:critical]} " +
            "-W #{node[:beanstalkd][:nagios][:growth_warning]} " +
            "-C #{node[:beanstalkd][:nagios][:growth_critical]}"
  end

  nagios_service "BEANSTALKD" do
    check_command "check_nrpe!check_beanstalkd"
  end
end

# ganymed
if ganymed?
  package 'dev-ruby/beanstalk-client'

  ganymed_collector 'beanstalk' do
    source 'beanstalk.rb'
  end
end
