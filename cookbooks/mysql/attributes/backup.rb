default[:mysql][:backup][:mode] = "copy" # or "stream"
default[:mysql][:backup][:keep] = "14" # keep 14 days worth of backup

# backup schedule (wday, hour)
default[:mysql][:backup][:full_backup]   = ['6', '11']
default[:mysql][:backup][:full_clean]    = ['0', '11']
default[:mysql][:backup][:binlog_clean]  = ['0', '15']

# options for stream mode
default[:mysql][:backup][:stream][:host] = nil
default[:mysql][:backup][:stream][:dir] = "~"

# options for copy mode
default[:mysql][:backup][:copy][:dir] = "/var/backup/mysql"
