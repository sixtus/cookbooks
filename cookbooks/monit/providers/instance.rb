include ChefUtils::Account

action :create do
  package "app-admin/monit"

  file "/etc/init.d/monit" do
    action :delete
  end

  directory "/etc/monit.d" do
    action :delete
    recursive true
  end

  file "/etc/monitrc" do
    action :delete
  end

  user = get_user(new_resource.name)
  pidfile = if user[:name] == "root"
              "/var/run/monit.pid"
            else
              "#{user[:dir]}/.monit.pid"
            end

  template "/etc/init.d/monit.#{user[:name]}" do
    source "monit.initd"
    cookbook "monit"
    owner "root"
    group "root"
    mode "0755"
    variables :user => user,
              :pidfile => pidfile
  end

  service "monit.#{user[:name]}" do
    action :nothing
  end

  if new_resource.manage
    template "#{user[:dir]}/.monitrc.local" do
      source new_resource.template
      owner user[:name]
      group user[:group][:name]
      variables :user => user
      notifies :restart, resources(:service => "monit.#{user[:name]}")
    end
  else
    file "#{user[:dir]}/.monitrc.local" do
      owner user[:name]
      group user[:group][:name]
    end
  end

  template "#{user[:dir]}/.monitrc" do
    source "monitrc"
    cookbook "monit"
    owner user[:name]
    group user[:group][:name]
    mode "0600"
    variables :user => user
    notifies :restart, resources(:service => "monit.#{user[:name]}")
  end

  service "monit.#{user[:name]}" do
    action [:enable, :start]
  end

  if node[:tags].include?("nagios-client")
    nrpe_command "check_monit_#{user[:name]}" do
      command "/usr/lib/nagios/plugins/check_pidfile #{pidfile} monit"
    end

    nagios_service "MONIT-#{user[:name].upcase}" do
      check_command "check_nrpe!check_monit_#{user[:name]}"
      servicegroups "monit"
    end
  end
end
