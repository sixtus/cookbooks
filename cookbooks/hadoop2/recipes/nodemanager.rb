include_recipe "hadoop2"

YARN_SERVICE = "nodemanager"
RESTARTS_ON = %w{
  yarn-site.xml
  mapred-site.xml
}

service "yarn@#{YARN_SERVICE}" do
  action [:enable, :start]
  
  RESTARTS_ON.each do |conf_file|
    subscribes :restart, "template[/etc/hadoop2/#{conf_file}]"
  end
end
