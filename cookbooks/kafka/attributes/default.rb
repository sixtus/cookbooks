default[:kafka][:git][:repository] = "https://github.com/apache/kafka"
default[:kafka][:git][:revision] = "0.8.1.1"

default[:kafka][:storage] = "/var/app/kafka/storage"

default[:kafka][:zookeeper][:root] = "/kafka.#{node.cluster_name}"
default[:kafka][:zookeeper][:cluster] = node.cluster_name

default[:kafka][:partition][:default] = 1
default[:kafka][:partition][:replication] = 1

default[:kafka][:log][:retention_hours] = 7*24

default[:kafka][:mirror][:topics] = [:users, :targeted_ids]
default[:kafka][:mirror][:sources] = [:eu1, :us1]
