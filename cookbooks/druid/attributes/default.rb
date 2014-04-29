default[:druid][:git][:repository] = "https://github.com/liquidm/druid"
default[:druid][:git][:revision] = "production"

default[:druid][:core_extensions] = [
  "s3-extensions",
  "hdfs-storage",
  "kafka-eight",
]

default[:druid][:extensions] = []
default[:druid][:monitors] = []
default[:druid][:logger] = false

default[:druid][:log4j][:full] = false

default[:druid][:cluster] = node.cluster_name
default[:druid][:service] = node.cluster_name

default[:druid][:zookeeper][:root]              = "/druid"
default[:druid][:zookeeper][:timeout]           = 30000
default[:druid][:zookeeper][:discovery]         = "/discovery"

default[:druid][:processing][:numThreads]       = [node[:cpu][:total]-1,1].max
default[:druid][:processing][:buffer]           = 1073741824

default[:druid][:broker][:port]                 = 8080
default[:druid][:broker][:mx]                   = "50g"
default[:druid][:broker][:dm]                   = "10g"
default[:druid][:broker][:cache_size_in_bytes]  = 42949672960
default[:druid][:broker][:connections]          = 20
default[:druid][:broker][:timeout]              = "PT10M"
default[:druid][:broker][:balancer]             = "connectionCount"

default[:druid][:coordinator][:port]            = 8081
default[:druid][:coordinator][:mx]              = "2g"
default[:druid][:coordinator][:dm]              = "64m"

default[:druid][:historical][:port]             = 8082
default[:druid][:historical][:mx]               = "15g"
default[:druid][:historical][:dm]               = "15g"

default[:druid][:realtime][:port]               = 8083
default[:druid][:realtime][:mx]                 = "12g"
default[:druid][:realtime][:dm]                 = "12g"
default[:druid][:realtime][:spec_files]         = %w{realtime}

default[:druid][:overlord][:port]               = 8090
default[:druid][:overlord][:mx]                 = "2g"
default[:druid][:overlord][:dm]                 = "64m"

default[:druid][:indexer][:port]                = 8091
default[:druid][:indexer][:mx]                  = "2g"
default[:druid][:indexer][:dm]                  = "64m"
default[:druid][:indexer][:runner][:javaOpts]   = "-d64 -server -Xmx1g"
default[:druid][:indexer][:runner][:startPort]  = 8092

default[:druid][:server][:max_size] = 0
default[:druid][:server][:tier] = "default"

default[:druid][:storage][:type] = "noop"

default[:druid][:storage][:s3][:access_key] = nil
default[:druid][:storage][:s3][:secret_key] = nil
default[:druid][:storage][:s3][:bucket] = nil
default[:druid][:storage][:s3][:base_key] = nil

default[:druid][:storage][:hdfs] = nil

default[:druid][:database][:uri] = "jdbc:mysql://127.0.0.1:3306/druid"
default[:druid][:database][:user] = "druid"
default[:druid][:database][:password] = "druid"

default[:druid][:nagios][:topics] = []
default[:druid][:nagios][:whitelist] = []

default[:dumbo][:git][:repository]      = "https://github.com/liquidm/druid-dumbo"
default[:dumbo][:git][:revision]        = "production"

default[:druid][:hadoop][:path]         = "/var/app/hadoop2/current/bin"
