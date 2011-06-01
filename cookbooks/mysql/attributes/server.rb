default[:contacts][:mysql] = "root@#{node[:fqdn]}"

# paths
default[:mysql][:server][:sharedstatedir] = "/usr/share/mysql"
default[:mysql][:server][:sysconfdir] = "/etc/mysql"
default[:mysql][:server][:libdir] = "/usr/lib/mysql"
default[:mysql][:server][:localstatedir] = "/var/lib/mysql"
default[:mysql][:server][:logdir] = "/var/log/mysql"
default[:mysql][:server][:rundir] = "/var/run/mysqld"
default[:mysql][:server][:includedir] = "/usr/include/mysql"
default[:mysql][:server][:datadir] = "/var/lib/mysql"
default[:mysql][:server][:tmpdir] = "/var/tmp"

# Startup & Security
default[:mysql][:server][:skip_networking] = false
default[:mysql][:server][:bind_address] = "127.0.0.1"
default[:mysql][:server][:skip_innodb] = false

# Replication & Binary Log
default[:mysql][:server][:server_id] = IPAddr.new(node[:ipaddress]).to_i
default[:mysql][:server][:slave_enabled] = false
default[:mysql][:server][:log_bin] = false
default[:mysql][:server][:sync_binlog] = "0"
default[:mysql][:server][:relay_log] = false
default[:mysql][:server][:expire_logs_days] = 14
default[:mysql][:server][:log_slave_updates] = false
default[:mysql][:server][:replicate_do_db] = false
default[:mysql][:server][:replicate_do_table] = false

if node[:mysql][:server][:slave_enabled]
  set[:mysql][:server][:log_bin] = true
  set[:mysql][:server][:relay_log] = true
end

# General Performance Options
default[:mysql][:server][:open_files_limit] = "4096"
default[:mysql][:server][:table_open_cache] = "1024"
default[:mysql][:server][:table_definition_cache] = "4096"
default[:mysql][:server][:thread_cache_size] = "16"
default[:mysql][:server][:tmp_table_size] = "64M"
default[:mysql][:server][:max_heap_table_size] = "64M"
default[:mysql][:server][:group_concat_max_len] = "1024"

if node[:mysql][:server][:max_heap_table_size].to_bytes < node[:mysql][:server][:tmp_table_size].to_bytes
  set[:mysql][:server][:max_heap_table_size] = node[:mysql][:server][:tmp_table_size]
end

# Client Connection Optimization
default[:mysql][:server][:max_connections] = "128"
default[:mysql][:server][:max_allowed_packet] = "16M"
default[:mysql][:server][:wait_timeout] = "28800"
default[:mysql][:server][:connect_timeout] = "10"

# Slow Query Log
default[:mysql][:server][:long_query_time] = "0"

# Key Buffer Optimization
default[:mysql][:server][:key_buffer_size] = "64M"

# Query Cache Optimization
default[:mysql][:server][:query_cache_size] = "128M"
default[:mysql][:server][:query_cache_type] = 1
default[:mysql][:server][:query_cache_limit] = "4M"

if node[:mysql][:server][:query_cache_type] == 0
  set[:mysql][:server][:query_cache_size] = 0
end

# Sort Optimization
default[:mysql][:server][:sort_buffer_size] = "4M"
default[:mysql][:server][:read_buffer_size] = "1M"
default[:mysql][:server][:read_rnd_buffer_size] = "512K"
default[:mysql][:server][:myisam_sort_buffer_size] = "64M"

# Join Optimization
default[:mysql][:server][:join_buffer_size] = "2M"

# InnoDB Options
default[:mysql][:server][:innodb_file_per_table] = true
default[:mysql][:server][:innodb_data_home_dir] = "/var/lib/mysql"
default[:mysql][:server][:innodb_buffer_pool_size] = "512M"
default[:mysql][:server][:innodb_log_file_size] = "256M"
default[:mysql][:server][:innodb_flush_log_at_trx_commit] = "1"
default[:mysql][:server][:innodb_thread_concurrency] = node[:cpu][:total] * 2 + 1
default[:mysql][:server][:innodb_lock_wait_timeout] = "50"

# Miscellaneous Options
default[:mysql][:server][:default_storage_engine] = "MyISAM"

# backup
default[:mysql][:backupdir] = "/var/backup/mysql"
default[:mysql][:backups] = {}
