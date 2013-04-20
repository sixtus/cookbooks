# triggers for other resources
execute "systemd-reload" do
  command "systemctl --system daemon-reload"
  action :nothing
  only_if { systemd_running? }
end

execute "systemd-tmpfiles" do
  command "systemd-tmpfiles --create"
  action :nothing
  only_if { systemd_running? }
end

case node[:platform]
when "gentoo"
  if root?
    portage_package_keywords "~sys-apps/dbus-1.6.8"
    portage_package_keywords "~sys-apps/systemd-200"

    portage_package_use "sys-apps/systemd" do
      use %w(static-libs python)
    end

    package "sys-apps/systemd"

    node.default[:portage][:USE] += %w(systemd)

    # by default, boot into multi-user.target
    service "multi-user.target" do
      action :enable
      provider Chef::Provider::Service::Systemd
    end

    template "/etc/systemd/system.conf" do
      source "system.conf"
      owner "root"
      group "root"
      mode "0644"
    end

    # journal
    service "systemd-journald.service" do
      action :nothing
      provider Chef::Provider::Service::Systemd
      only_if { systemd_running? }
    end

    template "/etc/systemd/journald.conf" do
      source "journald.conf"
      owner "root"
      group "root"
      mode "0644"
      notifies :restart, "service[systemd-journald.service]"
    end

    # networking
    file "/etc/hostname" do
      content "#{node[:hostname]}\n"
      owner "root"
      group "root"
      mode "0644"
    end

    link "/etc/ifup" do
      to "/etc/ifup.eth0"
      only_if { File.exist?("/etc/ifup.eth0") }
    end

    file "/etc/ifup" do
      owner "root"
      group "root"
      mode "0644"
    end

    file "/etc/ifdown" do
      owner "root"
      group "root"
      mode "0644"
    end

    systemd_unit "network.service"

    service "network.service" do
      action :enable
      provider Chef::Provider::Service::Systemd
    end

    service "sshd.service" do
      action :enable
      provider Chef::Provider::Service::Systemd
    end

    # user session support
    systemd_unit "systemd-stop-user-sessions.service"
    systemd_unit "user-session@.service"

    service "systemd-stop-user-sessions.service" do
      action :enable
      provider Chef::Provider::Service::Systemd
    end

    if tagged?("nagios-client")
      nagios_plugin "check_systemd"
      nagios_plugin "check_systemd_user"

      sudo_rule "nagios-systemd-active" do
        user "nagios"
        runas "ALL"
        command "NOPASSWD: /bin/env XDG_RUNTIME_DIR=/run/user/* systemctl --user is-active *"
      end

      sudo_rule "nagios-systemd-status" do
        user "nagios"
        runas "ALL"
        command "NOPASSWD: /bin/env XDG_RUNTIME_DIR=/run/user/* systemctl --user status *"
      end
    end
  end
end
