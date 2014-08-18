include_recipe "hadoop2"

service "yarn@nodemanager" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/hadoop2/core-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/hdfs-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/yarn-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/mapred-site.xml]"
end
