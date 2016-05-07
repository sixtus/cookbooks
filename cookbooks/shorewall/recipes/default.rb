unless vbox?
  # detect bridge
  if node[:network][:default_interface_bridged]
    shorewall_interface "br" do
      interface "#{node[:network][:default_interface]}:#{node[:network][:default_interface_bridged]}"
    end

    shorewall_zone "br:net" do
      type "bport"
    end

    shorewall_policy "br" do
      source "br"
      dest "all"
      policy "ACCEPT"
    end
  end

  if gentoo?
    package "net-firewall/conntrack-tools"

    package "net-firewall/shorewall-core" do
      action :remove
    end

    package "net-firewall/shorewall6" do
      action :remove
    end

    package "net-firewall/shorewall"
  elsif debian_based?
    package "shorewall"

    link "/usr/sbin/shorewall" do
      to "/sbin/shorewall"
    end

    package "shorewall6"

    link "/usr/sbin/shorewall6" do
      to "/sbin/shorewall6"
    end
  end

  include_recipe "shorewall::ipv4"
  include_recipe "shorewall::ipv6"

  if nagios_client?
    nagios_plugin "check_conntrack"

    nrpe_command "check_conntrack" do
      command "/usr/lib/nagios/plugins/check_conntrack 75 90"
    end

    nagios_service "CONNTRACK" do
      check_command "check_nrpe!check_conntrack"
      notification_interval 15
      servicegroups "network"
      env [:testing, :development]
    end
  end
end
