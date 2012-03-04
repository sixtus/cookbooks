include_recipe "postfix"
include_recipe "postfix::munin"

mynetworks = node.run_state[:nodes].select do |n|
  n[:primary_ipaddress]
end.map do |n|
  n[:primary_ipaddress]
end

mynetworks += node[:postfix][:mynetworks]

file "/etc/postfix/mynetworks" do
  content "#{mynetworks.sort.join("\n")}\n"
  owner "root"
  group "root"
  mode "0644"
end

postconf "allowed relay clients" do
  set :mynetworks => "127.0.0.1/32 /etc/postfix/mynetworks"
end
