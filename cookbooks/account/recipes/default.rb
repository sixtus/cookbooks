directory "/home" do
  owner "root"
  group "root"
  mode "0755"
end

# create hostmaster accounts
query = Proc.new do |u|
  if u[:tags] and u[:tags].include?("hostmaster")
    true
  elsif u[:nodes]
    u[:nodes][node[:fqdn]] and
    u[:nodes][node[:fqdn]][:tags] and
    u[:nodes][node[:fqdn]][:tags].include?("hostmaster")
  else
    false
  end
end

hostmaster_groups = %w(adm cron)

if gentoo?
  hostmaster_groups += %w(portage wheel systemd-journal)
elsif debian?
  hostmaster_groups += %w(sudo)
end

accounts_from_databag "hostmasters" do
  groups hostmaster_groups
  query query
end

# create node specific accounts
query = Proc.new do |u|
  u[:nodes] and u[:nodes][node[:fqdn]]
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
