define :mongodb_instance, :nfiles => "1024" do

  # rebind since params is not a scope variable, but a method call, which may
  # not be available in other scopes
  name = params[:name]
  port = params[:port]
  dbpath = params[:dbpath]
  dbpath ||= "/var/lib/mongodb/#{name}"

  # special case for default instance in mongodb::server mongodb::config
  svcname = if name == "mongodb"
              "mongodb"
            elsif name == "mongoc"
              "mongoc"
            else
              "mongodb.#{name}"
            end

  nagname = if name == "mongodb"
              "MONGODB"
            elsif name == "mongoc"
              "MONGOC"
            else
              "MONGODB-#{name.upcase}"
            end

  include_recipe "mongodb::default"

  # data for solr searches
  tag("mongodb")
  node[:mongodb][:instances][params[:name]] = params

  directory dbpath do
    owner "mongodb"
    group "root"
    mode "0755"
  end

  file "/var/log/mongodb/#{name}.log" do
    owner "mongodb"
    group "mongodb"
    mode "0644"
  end

  template "/etc/logrotate.d/#{svcname}" do
    source "mongodb.logrotate"
    owner "root"
    group "root"
    mode "0644"
    variables :name => name
  end

  syslog_config "90-#{svcname}" do
    template "syslog.conf"
    variables :name => name
  end

  cookbook_file "/etc/init.d/#{svcname}" do
    source "mongodb.initd"
    owner "root"
    group "root"
    mode "0755"
  end

  template "/etc/conf.d/#{svcname}" do
    source "mongodb.confd"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[#{svcname}]"
    variables :bind_ip => params[:bind_ip],
              :port => port,
              :dbpath => dbpath,
              :nfiles => params[:nfiles],
              :opts => params[:opts]
  end

  service svcname do
    action [:enable, :start]
  end

  if tagged?("nagios-client")
    nrpe_command "check_mongodb_#{name}" do
      command "/usr/lib/nagios/plugins/check_pidfile /var/run/mongodb/#{name}.pid mongod"
    end

    nagios_service nagname do
      check_command "check_nrpe!check_mongodb_#{name}"
      servicegroups "mongodb"
    end

    { # name             command         warn crit check note
      :connect     => %w(connect         2    5    1     15),
      :connections => %w(connections     80   90   1     15),
     #:flush       => %w(flushing        2    5    60    180),
      :lock        => %w(lock            2    5    60    180),
     #:memory      => %w(memory          2    5    5     180),
      :repl_lag    => %w(replication_lag 60   900  60    180),
      :repl_state  => %w(replset_state   0    0    1     15),
    }.each do |sname, p|
        sname = sname.to_s
        command_name = "check_mongodb_#{name}_#{sname}"
        service_name = "#{nagname}-#{sname.upcase.gsub(/_/, '-')}"

      nrpe_command command_name do
        command "/usr/lib/nagios/plugins/check_mongodb -H localhost -P #{port} -A #{p[0]} -W #{p[1]} -C #{p[2]}"
      end

      nagios_service service_name do
        check_command "check_nrpe!#{command_name}"
        check_interval p[3]
        notification_interval p[4]
        servicegroups "mongodb"
      end

      nagios_service_dependency service_name do
        depends [nagname]
      end
    end

    unless params[:opts].any? { |o| o.match(/--replSet/) }
      node.default[:nagios][:services]["#{nagname}-REPL-STATE"][:enabled] = false
      node.default[:nagios][:services]["#{nagname}-REPL-LAG"][:enabled] = false
    end
  end

  if tagged?("munin-node")
    %w(
      btree
      conn
      lock
      mem
      ops
    ).each do |p|
      munin_plugin "mongo_#{name}_#{p}" do
        plugin "mongo_#{p}"
        source "mongo_#{p}"
        config [
          "env.name #{name}",
          "env.port #{port.to_i + 1000}",
        ]
      end
    end
  end
end

define :mongos_instance do

  # rebind since params is not a scope variable, but a method call, which may
  # not be available in other scopes
  name = params[:name]

  # special case for default instance in mongodb::shard
  svcname = if name == "mongos"
              "mongos"
            else
              "mongos.#{name}"
            end

  nagname = if name == "mongos"
              "MONGOS"
            else
              "MONGOS-#{name.upcase}"
            end

  include_recipe "mongodb::default"

  tag("mongos")

  file "/var/log/mongodb/#{name}.log" do
    owner "mongodb"
    group "mongodb"
    mode "0644"
  end

  template "/etc/logrotate.d/#{svcname}" do
    source "mongodb.logrotate"
    owner "root"
    group "root"
    mode "0644"
    variables :name => name
  end

  syslog_config "90-#{svcname}" do
    template "syslog.conf"
    variables :name => name
  end

  cookbook_file "/etc/init.d/#{svcname}" do
    source "mongos.initd"
    owner "root"
    group "root"
    mode "0755"
  end

  template "/etc/conf.d/#{svcname}" do
    source "mongos.confd"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "service[#{svcname}]"
    variables :bind_ip => params[:bind_ip],
              :port => params[:port],
              :configdb => params[:configdb]
  end

  service svcname do
    action [:enable, :start]
  end

  if tagged?("nagios-client")
    nrpe_command "check_mongos_#{name}" do
      command "/usr/lib/nagios/plugins/check_pidfile /var/run/mongodb/#{name}.pid mongos"
    end

    nagios_service nagname do
      check_command "check_nrpe!check_mongos_#{name}"
      servicegroups "mongodb"
    end
  end
end
