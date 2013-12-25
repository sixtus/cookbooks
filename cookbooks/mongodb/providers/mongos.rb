action :create do
  name = new_resource.name

  # multiplex service
  svcname = "mongos-#{name}"

  # retrieve configdbs from index
  configdb = mongo_configdb_nodes(name).map do |n|
    "#{n[:fqdn]}:#{n[:mongoc][:port]}"
  end

  systemd_unit "#{svcname}.service" do
    template "mongos.service"
    notifies :restart, "service[#{svcname}]"
    variables({
      bind_ip: new_resource.bind_ip,
      port: new_resource.port,
      configdb: configdb,
      svcname: svcname,
    })
  end

  service svcname do
    action [:enable, :start]
  end
end

action :delete do
  name = new_resource.name

  # multiplex service
  svcname = "mongos-#{name}"

  service svcname do
    action [:disable, :stop]
  end
end

def initialize(*args)
  super
  @run_context.include_recipe "mongodb"
end
