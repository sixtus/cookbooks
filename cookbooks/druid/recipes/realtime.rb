include_recipe "druid"

node.default[:druid][:logger] = true

node[:druid][:realtime][:spec_files].each do |spec_name|
  service_name  = "druid-#{spec_name}"

  # the spec_file is not part of this recipe, as it is too specific
  spec_file     = "/etc/druid/#{spec_name}.spec"

  template "/usr/libexec/#{service_name}" do
    source "druid-runner.sh"
    owner "root"
    group "root"
    mode "0755"
    variables({
      druid_service:    "realtime",
      druid_port:       node[:druid][:realtime][:port],
      druid_mx:         node[:druid][:realtime][:mx],
      druid_dm:         node[:druid][:realtime][:dm],
      druid_spec_file:  spec_file,
    })

    notifies :restart, "service[#{service_name}]"
  end

  systemd_unit service_name do
    template "druid-service"
    variables({
      druid_service: service_name,
    })
    notifies :restart, "service[#{service_name}]"
  end

  service service_name do
    action [:enable, :start]
    subscribes :restart, "template[/etc/druid/runtime.properties]"
    subscribes :restart, "template[#{spec_file}]"
    # subscribes :restart, "template[/etc/druid/log4j.properties]"
  end
end
