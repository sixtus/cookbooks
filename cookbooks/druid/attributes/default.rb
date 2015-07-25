default[:druid][:git][:repository] = "https://github.com/druid-io/druid"
default[:druid][:git][:revision] = "druid-0.8.0"

default[:druid][:cluster] = node.cluster_name

default[:druid][:nagios][:topics] = []
default[:druid][:nagios][:whitelist] = []

# Modules
default[:druid][:core_extensions] = [
  "mysql-metadata-storage",
  "druid-hdfs-storage",
  "druid-kafka-eight",
  "druid-histogram",
]

default[:druid][:extensions] = []

# Curator Module
default[:druid][:zookeeper][:root] = "/druid"
default[:druid][:zookeeper][:timeout] = 6000

# Druid Processing Module
default[:druid][:processing][:buffer] = 1073741824
default[:druid][:processing][:numThreads] = [node[:cpu][:total]-1, 1].max
default[:druid][:processing][:memory] = (node[:druid][:processing][:buffer]*(node[:druid][:processing][:numThreads]+1)/1048576.0).ceil

# Storage Node Module
default[:druid][:server][:max_size] = 1 * 1024 * 1024 * 1024
default[:druid][:server][:tier] = "#{node[:cluster][:host][:group]}-#{node.cluster_name}"
default[:druid][:server][:priority] = 0

# DataSegment Pusher/Puller Module
default[:druid][:storage][:type] = "local"
default[:druid][:storage][:directory] = "/var/app/druid/storage"

# Discovery Module
default[:druid][:zookeeper][:discovery] = "/discovery"

# Coordinator Services
default[:druid][:coordinator][:port] = 8081
default[:druid][:coordinator][:mx] = 2 * 1024
default[:druid][:coordinator][:dm] = 64

# Broker Services
default[:druid][:broker][:port] = 8080
default[:druid][:broker][:mx] = node[:memory][:total].to_i/1024 - node[:druid][:processing][:memory] - node[:druid][:coordinator][:mx].to_i - 2048
default[:druid][:broker][:dm] = node[:druid][:processing][:memory]
default[:druid][:broker][:cache_size_in_bytes] = 42949672960
default[:druid][:broker][:connections] = 20
default[:druid][:broker][:timeout] = "PT10M"
default[:druid][:broker][:balancer] = "connectionCount"

# Realtime Services
default[:druid][:realtime][:port] = 8083
default[:druid][:realtime][:mx] = 12 * 1024
default[:druid][:realtime][:dm] = default[:druid][:processing][:memory]
default[:druid][:realtime][:partition] = IPAddr.new(node[:ipaddress]).to_i & (2**31-1)

# Historical Services
default[:druid][:historical][:port] = 8082
default[:druid][:historical][:mx] = node[:memory][:total].to_i/1024 - node[:druid][:processing][:memory] - 8192
default[:druid][:historical][:dm] = node[:druid][:processing][:memory]

# Overlord Services
default[:druid][:overlord][:port] = 8090
default[:druid][:overlord][:mx] = 2 * 1024
default[:druid][:overlord][:dm] = 64

# Middle Manager Services
default[:druid][:middleManager][:port] = 8091
default[:druid][:middleManager][:mx] = 2 * 1024
default[:druid][:middleManager][:dm] = 64

default[:druid][:worker][:capacity] = [node[:cpu][:total]/2,1].max
default[:druid][:indexer][:runner][:javaOpts] = "-d64 -server -Xmx8g -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+PrintGCDetails -XX:+PrintGCTimeStamps"
default[:druid][:indexer][:runner][:startPort] = 8092
