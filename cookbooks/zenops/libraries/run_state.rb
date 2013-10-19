module ZenopsRunStateHelpers
  def pkgsync_client_nodes
    node.run_state[:nodes].select do |n|
      n[:platform] == "gentoo" and
      n[:portage][:repo] == "zentoo"
    end
  end

  def zenops_mirror_node
    node.run_state[:nodes].select do |n|
      n.role?("zenops-mirror")
    end.first
  end
end

include ZenopsRunStateHelpers

class Zenops
  class Recipe
    include ZenopsRunStateHelpers
  end

  class Node
    include ZenopsRunStateHelpers
  end

  class Resource
    include ZenopsRunStateHelpers
  end
end
