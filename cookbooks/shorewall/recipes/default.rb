# reset all attributes to make sure cruft is being deleted on chef-client run
node.set[:shorewall][:accounting] = {}
node.set[:shorewall6][:accounting] = {}
node.set[:shorewall][:hosts] = {}
node.set[:shorewall6][:hosts] = {}
node.set[:shorewall][:interfaces] = {}
node.set[:shorewall6][:interfaces] = {}
node.set[:shorewall][:policies] = {}
node.set[:shorewall6][:policies] = {}
node.set[:shorewall][:rules] = {}
node.set[:shorewall6][:rules] = {}
node.set[:shorewall][:tunnels] = {}
node.set[:shorewall6][:tunnels] = {}
node.set[:shorewall][:zones] = {}
node.set[:shorewall6][:zones] = {}

include_recipe "shorewall::rules"

# LXC support
if node[:primary_interface] == "lxc0"
  shorewall_lxc_bridge "lxc" do
    interface node[:primary_interface]
    bridged node[:primary_interface_bridged]
  end
end

include_recipe "shorewall::ipv4"

if node[:ipv6_enabled]
  include_recipe "shorewall::ipv6"
end

if tagged?("nagios-client")
  nagios_plugin "check_conntrack"

  nrpe_command "check_conntrack" do
    command "/usr/lib/nagios/plugins/check_conntrack 75 90"
  end

  nagios_service "CONNTRACK" do
    check_command "check_nrpe!check_conntrack"
    notification_interval 15
    servicegroups "system"
    env [:testing, :development]
  end
end
