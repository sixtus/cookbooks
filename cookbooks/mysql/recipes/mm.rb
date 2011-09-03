node.set[:mysql][:server][:bind_address] = "0.0.0.0"

node.set[:mysql][:server][:slave_enabled] = true
node.set[:mysql][:server][:log_slave_updates] = true

node.set[:mysql][:server][:nagios][:index][:enabled] = node[:mysql][:server][:active_master]
node.set[:mysql][:server][:nagios][:kchit][:enabled] = node[:mysql][:server][:active_master]
node.set[:mysql][:server][:nagios][:qchit][:enabled] = node[:mysql][:server][:active_master]

# reload attributes files to make the magic happen
node.load_attribute_by_short_filename('server', 'mysql')

include_recipe "mysql::server"
