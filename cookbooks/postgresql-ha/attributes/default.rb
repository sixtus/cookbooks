# connection info (overriden in server recipe)
default[:postgresql][:connection][:host] = 'localhost'
default[:postgresql][:connection][:username] = 'postgres'
default[:postgresql][:connection][:password] = ''

# Connections and Authentication
default[:postgresql][:server][:version] = "9.4"
default[:postgresql][:server][:listen_address] = "0.0.0.0"
default[:postgresql][:server][:port] = 5432
default[:postgresql][:server][:max_connections] = 500
default[:postgresql][:server][:authentication_timeout] = "1min"

# Resource Consumption
default[:postgresql][:server][:shared_buffers] = "#{[(node[:memory][:total].to_i/1024/4),130].max}MB"
default[:postgresql][:server][:temp_buffers] = "8MB"
default[:postgresql][:server][:work_mem] = "1MB"
default[:postgresql][:server][:maintenance_work_mem] = "16MB"

# Write Ahead Log
default[:postgresql][:server][:wal_level] = "logical"
default[:postgresql][:server][:wal_buffers] = -1
default[:postgresql][:server][:checkpoint_segments] = 3
default[:postgresql][:server][:checkpoint_completion_target] = 0.5
default[:postgresql][:server][:max_wal_senders] = 10
default[:postgresql][:server][:wal_keep_segments] = 1024 # 16G of segments
default[:postgresql][:server][:max_replication_slots] = 5

# Planner Cost Constants
default[:postgresql][:server][:effective_cache_size] = "128MB"

# Hourly snapshots
default[:postgresql][:snapshot][:path] = "/var/app/postgresql/snapshots"

# HA
default[:postgresql][:ha][:group] = node.production? ? node.chef_environment : "dev"
default[:postgresql][:ha][:cluster] = node.production? ? node[:cluster][:name].gsub(".", "_") : "dev"
default[:postgresql][:ha][:pgbouncer] = "1.7"
default[:postgresql][:ha][:client_port] = 6432
