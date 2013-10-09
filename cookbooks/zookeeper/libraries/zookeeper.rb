module ZookeeperHelpers
  def zookeeper_nodes
    node.run_state[:nodes].select do |n|
      n[:tags] and
      n[:tags].include?("zookeeper") and
      n[:zookeeper] and
      n[:zookeeper][:ensemble] == node[:zookeeper][:ensemble]
    end.sort_by do |n|
      n[:fqdn]
    end
  end

  def zookeeper_node_names
    zookeeper_nodes.map do |n|
      n[:fqdn]
    end
  end

  def zookeeper_url
    zookeeper_node_names.map do |fqdn|
      "#{fqdn}:2181"
    end.join(',')
  end
end

include ZookeeperHelpers

class Chef
  class Recipe
    include ZookeeperHelpers
  end

  class Node
    include ZookeeperHelpers
  end

  class Resource
    include ZookeeperHelpers
  end
end
