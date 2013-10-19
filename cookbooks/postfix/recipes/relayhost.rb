include_recipe "postfix"

file "/etc/postfix/mynetworks" do
  content "#{postfix_networks.sort.join("\n")}\n"
  owner "root"
  group "root"
  mode "0644"
end

postconf "allowed relay clients" do
  set :mynetworks => "127.0.0.1/32 /etc/postfix/mynetworks"
end
