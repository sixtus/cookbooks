# Connections and Authentication
default[:postgresql][:server][:listen_address] = "127.0.0.1"
default[:postgresql][:server][:port] = 5432
default[:postgresql][:server][:max_connections] = 100
default[:postgresql][:server][:authentication_timeout] = "1min"

# Resource Consumption
default[:postgresql][:server][:shared_buffers] = "24MB"
default[:postgresql][:server][:temp_buffers] = "8MB"
default[:postgresql][:server][:work_mem] = "1MB"
default[:postgresql][:server][:maintenance_work_mem] = "16MB"

# Write Ahead Log
default[:postgresql][:server][:wal_level] = "minimal"
default[:postgresql][:server][:checkpoint_segments] = 3
default[:postgresql][:server][:max_wal_senders] = 0
default[:postgresql][:server][:wal_keep_segments] = 0
default[:postgresql][:server][:hot_standby] = "off"
