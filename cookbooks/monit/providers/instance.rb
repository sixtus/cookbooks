include ChefUtils::Account
include ChefUtils::RandomResource

action :create do
  file "/etc/init.d/monit-#{rrand}" do
    path "/etc/init.d/monit"
    action :delete
  end

  directory "/etc/monit.d-#{rrand}" do
    path "/etc/monit.d"
    action :delete
    recursive true
  end

  file "/etc/monitrc-#{rrand}" do
    path "/etc/monitrc"
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

  if new_resource.manage
    template "#{user[:dir]}/.monitrc.local" do
      source new_resource.template
      owner user[:name]
      group user[:group][:name]
      variables :user => user
      notifies :restart, "service[monit.#{user[:name]}]"
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
    notifies :restart, "service[monit.#{user[:name]}]"
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

def initialize(*args)
  super
  @action = :create
  @run_context.include_recipe "monit"
end
