# to make things faster, load data from search index into run_state
if solo?
  node.run_state[:roles] = []
  node.run_state[:users] = []
  node.run_state[:nodes] = [node]
else
  node.run_state[:roles] = search(:role)
  node.run_state[:users] = search(:users)
  node.run_state[:nodes] = search(:node, "primary_ipaddress:[* TO *] AND fqdn:[* TO *]").sort_by do |n|
    n[:fqdn]
  end
end

# filter nodes that belong to the same cluster as the current node
node.run_state[:cluster_nodes] = node.run_state[:nodes].select do |n|
  n[:cluster][:name] == node[:cluster][:name] rescue false
end
