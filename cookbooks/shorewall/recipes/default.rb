# reset all attributes to make sure cruft is being deleted on chef-client run
node[:shorewall][:accounting] = {}
node[:shorewall6][:accounting] = {}
node[:shorewall][:hosts] = {}
node[:shorewall6][:hosts] = {}
node[:shorewall][:interfaces] = {}
node[:shorewall6][:interfaces] = {}
node[:shorewall][:policies] = {}
node[:shorewall6][:policies] = {}
node[:shorewall][:rules] = {}
node[:shorewall6][:rules] = {}
node[:shorewall][:tunnels] = {}
node[:shorewall6][:tunnels] = {}
node[:shorewall][:zones] = {}
node[:shorewall6][:zones] = {}

include_recipe "shorewall::rules"

# binhost rules
node.run_state[:nodes].select do |n|
  n[:tags].include?("portage-binhost")
end.each do |n|
  if n[:primary_ipaddress]
    shorewall_rule "portage-binhost@#{n[:fqdn]}" do
      source "net:#{n[:primary_ipaddress]}"
      destport "rsync"
    end
  end

  if n[:primary_ip6address]
    shorewall6_rule "portage-binhost@#{n[:fqdn]}" do
      source "net:<#{n[:primary_ip6address]}>"
      destport "rsync"
    end
  end
end

# nagios rules
node.run_state[:nodes].select do |n|
  n[:tags].include?("nagios-master")
end.each do |n|
  if n[:primary_ipaddress]
    shorewall_rule "nagios-master@#{n[:fqdn]}" do
      source "net:#{n[:primary_ipaddress]}"
      destport "4949,5666"
    end
  end

  if n[:primary_ip6address]
    shorewall6_rule "nagios-master@#{n[:fqdn]}" do
      source "net:<#{n[:primary_ip6address]}>"
      destport "5666"
    end
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
  end

  nagios_service_escalation "CONNTRACK"
end
