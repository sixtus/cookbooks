include_recipe "hadoop2"

service "hdfs@datanode" do
  action [:enable, :start]
  subscribes :restart, "template[/etc/hadoop2/core-site.xml]"
  subscribes :restart, "template[/etc/hadoop2/hdfs-site.xml]"
end
