default[:backup][:encryption_password] = 'sekrit'
default[:backup][:target_base_url] = "file:///var/backup"

# seed with host specific data to make it idempotent
srand(IPAddr.new(node[:ipaddress]).to_i)
default[:duply][:backup_time] = "#{rand(2..5)}:#{rand(15..45)}"
