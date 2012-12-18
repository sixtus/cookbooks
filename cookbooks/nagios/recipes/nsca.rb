portage_package_use "net-analyzer/nsca" do
  use %w(minimal)
end

package "net-analyzer/nsca" do
  action :upgrade
end

include_recipe "nagios::default"

master = node.run_state[:nodes].select do |n|
  n[:tags].include?("nagios-master")
end.first

template "/etc/nagios/send_nsca.cfg" do
  source "send_nsca.cfg.erb"
  owner "nagios"
  group "nagios"
  mode "0640"
  variables :master => master
end
