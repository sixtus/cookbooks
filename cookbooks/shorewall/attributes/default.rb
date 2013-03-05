set_unless[:shorewall][:hosts] = {}
set_unless[:shorewall6][:hosts] = {}
set_unless[:shorewall][:interfaces] = {}
set_unless[:shorewall6][:interfaces] = {}
set_unless[:shorewall][:policies] = {}
set_unless[:shorewall6][:policies] = {}
set_unless[:shorewall][:rules] = {}
set_unless[:shorewall6][:rules] = {}
set_unless[:shorewall][:tunnels] = {}
set_unless[:shorewall6][:tunnels] = {}
set_unless[:shorewall][:zones] = {}
set_unless[:shorewall6][:zones] = {}

# detect bridge device
link = %x(ip link show)
       .split(/\n/)
       .select { |line| line =~ /master #{node[:primary_interface]}/ }
       .map { |line| line.split[1].sub(/:$/, '') }
       .reject { |device| device =~ /^veth/ }

case link.size
when 0
  default[:primary_interface_bridged] = false
when 1
  default[:primary_interface_bridged] = link.first
else
  raise "failed to identify bridged interface" unless node[:primary_interface_bridged]
end
