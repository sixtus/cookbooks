module SmcHelpers
  def smc_nodes(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("smc")
  end
end

include SmcHelpers

class Smc
  class Recipe
    include SmcHelpers
  end

  class Node
    include SmcHelpers
  end

  class Resource
    include SmcHelpers
  end
end
