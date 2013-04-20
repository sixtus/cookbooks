action :create do
  name = new_resource.name

  # multiplex service
  svcname = "mongos.#{name}"
  nagname = svcname.upcase.gsub(/\./, '-')

  # retrieve configdbs from index
  configdb = node.run_state[:nodes].select do |n|
    n[:tags] and n[:tags].include?("mongoc-#{name}")
  end.map do |n|
    "#{n[:fqdn]}:#{n[:mongoc][:port]}"
  end.sort

  file "/var/log/mongodb/#{svcname}.log" do
    owner "mongodb"
    group "mongodb"
    mode "0644"
    action :delete if systemd_running?
  end

  template "/etc/logrotate.d/#{svcname}" do
    source "mongodb.logrotate"
    owner "root"
    group "root"
    mode "0644"
    variables :name => name
    action :delete if systemd_running?
  end

  cookbook_file "/etc/init.d/#{svcname}" do
    source "mongos.initd"
    owner "root"
    group "root"
    mode "0755"
    action :delete if systemd_running?
  end

  template "/etc/conf.d/#{svcname}" do
    source "mongos.confd"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[#{svcname}]"
    variables :bind_ip => new_resource.bind_ip,
              :port => new_resource.port,
              :configdb => configdb
  end

  service svcname do
    action [:enable, :start]
  end

  if node[:tags].include?("nagios-client")
    nrpe_command "check_mongos_#{name}" do
      command "/usr/lib/nagios/plugins/check_systemd mongos@#{name}.service /run/mongodb/#{svcname}.pid mongos"
    end

    nagios_service nagname do
      check_command "check_nrpe!check_mongos_#{name}"
      servicegroups "mongodb"
    end
  end
end

action :delete do
  name = new_resource.name

  # multiplex service
  svcname = "mongos.#{name}"

  service svcname do
    action [:disable, :stop]
  end

  file "/etc/logrotate.d/#{svcname}" do
    action :delete
  end

  file "/etc/init.d/#{svcname}" do
    action :delete
  end

  file "/etc/conf.d/#{svcname}" do
    action :delete
  end
end

def initialize(*args)
  super
  @run_context.include_recipe "mongodb"
end
