default[:camus][:git][:repository] = "https://github.com/remerge/camus"

# no topics means all topics
default[:camus][:topics] = {}

default[:camus][:destination] = "/history/#{node.cluster_name}"
default[:camus][:base_path] = "/camus/#{node.cluster_name}/running"
default[:camus][:history_path] = "/camus/#{node.cluster_name}/state"
