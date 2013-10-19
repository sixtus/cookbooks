include_recipe "hadoop"

service "hadoop@tasktracker" do
  action [:enable, :start]
end
