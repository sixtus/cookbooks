default[:camus][:git][:repository] = "https://github.com/linkedin/camus"
default[:camus][:git][:revision] = "master"

default[:camus][:cluster] = node.cluster_name
default[:camus][:topics] = nil

default[:camus][:etl][:destination] = "/history/#{node.cluster_name}"
default[:camus][:etl][:base_path] = "/camus/#{node.cluster_name}/running"
default[:camus][:etl][:history_path] = "/camus/#{node.cluster_name}/state"
default[:camus][:etl][:writer] = "com.linkedin.camus.etl.kafka.common.JSONRecordWriterProvider"

default[:camus][:message][:decoder] = "com.linkedin.camus.etl.kafka.coders.JsonStringMessageDecoder"
default[:camus][:message][:timestamp][:field] = "ts"
default[:camus][:message][:timestamp][:format] = "yyyy-MM-dd'T'HH:mm:ss'Z'"

default[:camus][:hadoop][:path] = "/var/app/hadoop2/current/bin"
