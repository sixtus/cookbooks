include_recipe "hadoop"

service "hadoop@tasktracker" do
  action [:enable, :start]
  subscribes :restart, 'template[/opt/hadoop/conf/mapred-site.xml]'
end
