if gentoo?
  package "sys-apps/smartmontools"

elsif debian_based?
  package "smartmontools"
end

if node[:smart][:devices].any?
  cookbook_file "/usr/local/sbin/diskreport" do
    source "diskreport.sh"
    owner "root"
    group "root"
    mode "0755"
  end

  template "/etc/smartd.conf" do
    source "smartd.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[smartd]"
  end

  systemd_unit "smartd.service"

  if node[:smart][:devices].empty?
    service "smartd" do
      service_name "smartd"
      service_name "smartmontools" if debian_based?
      action [:disable, :stop]
    end
  else
    service "smartd" do
      service_name "smartd"
      service_name "smartmontools" if debian_based?
      action [:enable, :start]
    end
  end

  if nagios_client?
    nagios_plugin "check_smart"

    sudo_rule "nagios-smartctl" do
      user "nagios"
      runas "root"
      command "NOPASSWD: /usr/sbin/smartctl"
    end

    node[:smart][:devices].each do |d|
      devname = d.sub("/dev/", "")

      nrpe_command "check_smart_#{devname}" do
        command "/usr/lib/nagios/plugins/check_smart -d #{d} -i ata"
      end

      nagios_service "SMART_#{devname.upcase}" do
        check_command "check_nrpe!check_smart_#{devname}"
        check_interval 60
        notification_interval 180
        env [:testing, :development]
      end
    end
  end
end
