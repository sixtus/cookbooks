# to make things faster, load data from search index into run_state
if solo?
  node.run_state[:nodes] = []
  node.run_state[:roles] = []
  node.run_state[:users] = []
else
  node.run_state[:nodes] = search(:node, "primary_ipaddress:[* TO *]")
  node.run_state[:roles] = search(:role)
  node.run_state[:users] = search(:users)
end

# select basic infrastructure nodes from the index for easy access in recipes
{
  :chef => "chef",
  :splunk => "splunk-indexer",
  :nagios => "nagios",
  :mx => "mx",
}.each do |key, role|
  node.run_state[key] = node.run_state[:nodes].select do |n|
    n.role?(role)
  end
end

# need this for bootstrapping the chef server
if node.role?("chef")
  node.run_state[:chef] = [node]
end

if node.run_state[:chef].any?
  node.set[:chef_domain] = node.run_state[:chef].first[:domain]

  # this is awful but needed to keep attribute precedence
  node.load_attributes
  node.apply_expansion_attributes(node.expand!('server'))
end

if node.run_state[:nagios].any?
  tag("nagios-client")
end

# create script path
directory node[:script_path] do
  owner Process.euid
  mode "0755"
end

include_recipe "base::linux" if node[:os] == "linux"
include_recipe "base::mac_os_x" if node[:platform] == "mac_os_x"

# install base packages
node[:packages].each do |pkg|
  package pkg
end

# load common recipes
include_recipe "bash"
include_recipe "git"
include_recipe "htop"
include_recipe "lftp"
include_recipe "ssh"
include_recipe "tmux"
include_recipe "vim"
