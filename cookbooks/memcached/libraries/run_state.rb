module MemcachedHelpers
  def memcached_nodes(cluster_name = node.cluster_name, fallback = nil)
    k = node.nodes.cluster(cluster_name).role("memcached")
    k = node.nodes.cluster(fallback).role("memcached") if fallback && k.empty?
    k
  end
end

include MemcachedHelpers

class Chef
  class Recipe
    include MemcachedHelpers
  end

  class Node
    include MemcachedHelpers
  end

  class Resource
    include MemcachedHelpers
  end
end
