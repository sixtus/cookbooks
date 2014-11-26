module AerospikeHelpers
  def aerospike_nodes(cluster_name = node.cluster_name, fallback = nil)
    k = node.nodes.cluster(cluster_name).role("aerospike")
    k = node.nodes.cluster(fallback).role("aerospike") if fallback && k.empty?
    k
  end
end

include AerospikeHelpers

class Aerospike
  class Recipe
    include AerospikeHelpers
  end

  class Node
    include AerospikeHelpers
  end

  class Resource
    include AerospikeHelpers
  end
end
