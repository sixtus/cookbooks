module ZookeeperRunStateHelpers
  def zookeeper_nodes(ensemble = nil)
    ensemble ||= node[:zookeeper][:ensemble]
    node.run_state[:nodes].select do |n|
      n.role?("zookeeper") and
      n[:zookeeper] and
      n[:zookeeper][:ensemble] == ensemble
    end
  end

  def zookeeper_url(ensemble = nil)
    zookeeper_nodes(ensemble).map do |n|
      "#{n[:fqdn]}:2181"
    end.join(',')
  end
end

include ZookeeperRunStateHelpers

class Chef
  class Recipe
    include ZookeeperRunStateHelpers
  end

  class Node
    include ZookeeperRunStateHelpers
  end

  class Resource
    include ZookeeperRunStateHelpers
  end
end
