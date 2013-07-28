case node[:platform]
when "gentoo"
  package "app-misc/beanstalkd"

  systemd_unit "beanstalkd.service"

  service "beanstalkd" do
    action [:enable, :start]
    only_if { root? }
  end

when "mac_os_x"
  package "beanstalk"

end

# nagios
if tagged?("nagios-client")
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
if tagged?('ganymed-client')
  package 'dev-ruby/beanstalk-client'

  ganymed_collector 'beanstalk' do
    source 'beanstalk.rb'
  end
end
