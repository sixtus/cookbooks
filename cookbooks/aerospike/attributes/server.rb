default[:aerospike][:fd_max] = 50000
default[:aerospike][:namespaces][:test] = {
  replication_factor: 2,
  memory_size: "16M",
  default_ttl: "30d",
  storage_engine: "memory",
}
