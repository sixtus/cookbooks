default[:nagios][:from_address] = "nagios@#{node[:fqdn]}"
default[:nagios][:nsca][:password] = "n6JlHK3zql33QpQiiNWk1rC5XQsDk8KB"
default[:nagios][:notifier] = "noop"
default[:nagios][:vhosts] = []

default[:nagios][:calendar][:scope] = nil
default[:nagios][:calendar][:client_id] = nil
default[:nagios][:calendar][:client_secret] = nil
default[:nagios][:calendar][:refresh_token] = nil
default[:nagios][:calendar][:access_token] = nil
default[:nagios][:calendar][:calendar_id] = nil
