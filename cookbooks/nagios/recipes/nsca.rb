is_master = tagged?("nagios-master")

case node[:platform]
when "gentoo"
  portage_package_use "net-analyzer/nsca" do
    use %w(minimal) unless is_master
  end

  package "net-analyzer/nsca" do
    action :upgrade
  end

when "debian"
  package "nsca"
end

include_recipe "nagios"

master = node.run_state[:nodes].select do |n|
  n[:tags].include?("nagios-master") rescue false
end.first

template "/etc/nagios/send_nsca.cfg" do
  source "send_nsca.cfg.erb"
  owner "nagios"
  group "nagios"
  mode "0640"
  variables :master => master
end
