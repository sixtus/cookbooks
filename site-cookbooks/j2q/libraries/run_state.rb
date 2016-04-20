module J2qHelpers
  def j2q_nodes(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("j2q")
  end
end

include J2qHelpers

class J2q
  class Recipe
    include J2qHelpers
  end

  class Node
    include J2qHelpers
  end

  class Resource
    include J2qHelpers
  end
end
