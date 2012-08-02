package "dev-db/redis"

service "redis" do
  action [:enable, :start]
end
