default[:camus][:git][:repository] = "https://github.com/linkedin/camus"
default[:camus][:git][:revision] = "master"

default[:camus][:topics] = nil

default[:camus][:etl][:destination] = "/history/#{node.cluster_name}"
default[:camus][:etl][:base_path] = "/camus/#{node.cluster_name}/running"
default[:camus][:etl][:history_path] = "/camus/#{node.cluster_name}/state"
