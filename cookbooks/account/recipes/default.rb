directory "/home" do
  owner "root"
  group "root"
  mode "0755"
end

# create hostmaster accounts
query = Proc.new do |u|
  u[:tags] and u[:tags].include?("hostmaster")
end

accounts_from_databag "hostmasters" do
  groups %w(cron portage wheel)
  query query
end

# create node specific accounts
query = Proc.new do |u|
  u[:hosts] and u[:hosts].include?(node[:fqdn])
end

accounts_from_databag "node-specific" do
  query query
end

query = Proc.new do |u|
  u[:tags] and not (node[:account][:tags] & u[:tags]).empty?
end

accounts_from_databag "node-tags" do
  query query
end
