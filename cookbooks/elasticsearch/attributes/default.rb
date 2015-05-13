default[:elasticsearch][:version] = "1.5.2"
default[:elasticsearch][:kibana][:version] = "4.0.2-linux-x64"

# don't cross 32g, see http://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html
default[:elasticsearch][:heap_size] = "#{[(node[:memory][:total].to_i / 1024 / 1024 / 2), 32].min}g"

default[:elasticsearch][:cluster] = node.cluster_name
default[:elasticsearch][:rack] = node.cluster_name


# You can exploit these settings to design advanced cluster topologies.
#
# 1. You want this node to never become a master node, only to hold data.
#    This will be the "workhorse" of your cluster.
#
#node.master: false
#node.data: true
#
# 2. You want this node to only serve as a master: to not store any data and
#    to have free resources. This will be the "coordinator" of your cluster.
#
#node.master: true
#node.data: false
#
# 3. You want this node to be neither master nor data node, but
#    to act as a "search load balancer" (fetching data from nodes,
#    aggregating results, etc.)
#
#node.master: false
#node.data: false
default[:elasticsearch][:master] = true
default[:elasticsearch][:data] = true

# 1. Having more *shards* enhances the _indexing_ performance and allows to
#    _distribute_ a big index across machines.
# 2. Having more *replicas* enhances the _search_ performance and improves the
#    cluster _availability_.
default[:elasticsearch][:index][:shards] = 5
default[:elasticsearch][:index][:replicas] = 1

default[:elasticsearch][:journald][:git] = "https://github.com/liquidm/elastic-journald"
default[:elasticsearch][:journald][:revision] = "production"
default[:elasticsearch][:journald][:cluster] = "dw"

default[:elasticsearch][:kibana][:server_name] = "kibana.#{node[:chef_domain]}"
default[:elasticsearch][:kibana][:certificate] = "wildcard.#{node[:chef_domain]}"

default[:elasticsearch][:curator][:keep_days] = 60
default[:elasticsearch][:curator][:reduced_replica_days] = 7
