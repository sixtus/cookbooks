package value_for_platform({
  "gentoo" => {"default" => "app-misc/beanstalkd"},
  "mac_os_x" => {"default" => "beanstalk"},
})

if platform?("gentoo")
  template "/etc/conf.d/beanstalkd" do
    source "beanstalkd.confd.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[beanstalkd]"
  end

  service "beanstalkd" do
    action [:enable, :start]
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
end
