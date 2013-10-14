# to make things faster, load data from search index into run_state
if solo?
  node.run_state[:nodes] = [node]
  node.run_state[:roles] = []
  node.run_state[:users] = []
else
  node.run_state[:nodes] = search(:node, "primary_ipaddress:[* TO *]")
  node.run_state[:roles] = search(:role)
  node.run_state[:users] = search(:users)
end

# select basic infrastructure nodes from the index for easy access in recipes
%w(
  chef
  splunk
  splunk-master
  splunk-peer
  splunk-search
  splunk-server
  nagios
  mx
  zenops-mirror
).each do |role|
  node.run_state[role.to_sym] = node.run_state[:nodes].select do |n|
    n[:roles] and n[:roles].include?(role)
  end
end

# need this for bootstrapping the chef server
if node.role?("chef")
  node.run_state[:chef] = [node]
end

if node.run_state[:chef].any?
  node.set[:chef_domain] = node.run_state[:chef].first[:domain]
else
  node.set[:chef_domain] = node[:domain]
end

# this is awful but needed to keep attribute precedence
node.load_attributes if node.respond_to?(:load_attributes)

if solo?
  node.apply_expansion_attributes(node.expand!('disk'))
else
  node.apply_expansion_attributes(node.expand!('server'))
end

if node.run_state[:nagios].any?
  tag("nagios-client")
end
