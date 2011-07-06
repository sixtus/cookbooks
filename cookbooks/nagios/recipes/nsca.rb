package "net-analyzer/nagios-nsca"

directory "/etc/nagios" do
  owner "nagios"
  group "nagios"
  mode "0750"
end

master = node.run_state[:nodes].select do |n|
  n[:tags].include?("nagios-master")
end.first

nagios_conf "send_nsca" do
  subdir false
  mode "0640"
  variables :master => master
end
