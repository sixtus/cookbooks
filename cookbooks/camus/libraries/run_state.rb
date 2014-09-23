module CamusRunStateHelpers
  def camus_nodes(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("camus")
  end
end

include CamusRunStateHelpers

class Chef
  class Recipe
    include CamusRunStateHelpers
  end

  class Node
    include CamusRunStateHelpers
  end

  class Resource
    include CamusRunStateHelpers
  end
end
