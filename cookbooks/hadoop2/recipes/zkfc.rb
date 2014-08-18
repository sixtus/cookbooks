include_recipe "hadoop2"

service "hdfs@zkfc" do
  action [:enable, :start]
  only_if { hadoop2_namenodes.count > 1 }
  subscribes :restart, "template[/etc/hadoop2/core-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/hdfs-site.xml]"
end
