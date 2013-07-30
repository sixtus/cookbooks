tag("hadoop-jobtracker")

include_recipe "hadoop"

service "hadoop@jobtracker" do
  action [:enable, :start]
end
