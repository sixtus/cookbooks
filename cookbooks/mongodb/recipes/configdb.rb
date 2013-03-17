tag("mongoc")
tag("mongoc-#{node[:mongodb][:cluster]}")

opts = %w(--journal --rest --quiet --configsvr)

directory node[:mongoc][:dbpath] do
  owner "mongodb"
  group "root"
  mode "0755"
end

file "/var/log/mongodb/mongoc.log" do
  owner "mongodb"
  group "mongodb"
  mode "0644"
end

splunk_input "monitor:///var/log/mongodb/mongoc.log"

template "/etc/logrotate.d/mongoc" do
  source "mongodb.logrotate"
  owner "root"
  group "root"
  mode "0644"
  variables :name => "mongoc"
end

cookbook_file "/etc/init.d/mongoc" do
  source "mongodb.initd"
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/conf.d/mongoc" do
  source "mongodb.confd"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[mongoc]"
  variables :bind_ip => node[:mongoc][:bind_ip],
            :port => node[:mongoc][:port],
            :dbpath => node[:mongoc][:dbpath],
            :nfiles => node[:mongoc][:nfiles],
            :opts => opts
end

systemd_unit "mongoc.service"

service "mongoc" do
  action [:enable, :start]
end

if tagged?("ganymed-client")
  ganymed_collector "mongoc" do
    source "mongodb.rb"
    variables :name => "mongoc",
              :port => node[:mongoc][:port]
  end
end

if tagged?("nagios-client")
  nrpe_command "check_mongoc" do
    command "/usr/lib/nagios/plugins/check_systemd mongoc.service /run/mongodb/mongoc.pid mongod"
  end

  nagios_service "MONGOC" do
    check_command "check_nrpe!check_mongoc"
    servicegroups "mongodb"
  end

  { # name             command         warn crit check note
    :connect     => %w(connect         2    5    1     15),
    :connections => %w(connections     80   90   1     15),
    :lock        => %w(lock            75   90   60    180),
  }.each do |name, p|
      name = name.to_s
      command_name = "check_mongoc_#{name}"
      service_name = "MONGOC-#{name.upcase.gsub(/_/, '-')}"

    nrpe_command command_name do
      command "/usr/lib/nagios/plugins/check_mongodb -H localhost -P #{node[:mongoc][:port]} -A #{p[0]} -W #{p[1]} -C #{p[2]}"
    end

    nagios_service service_name do
      check_command "check_nrpe!#{command_name}"
      check_interval p[3]
      notification_interval p[4]
      servicegroups "mongodb"
    end

    nagios_service_dependency service_name do
      depends ["MONGOC"]
    end
  end
end
