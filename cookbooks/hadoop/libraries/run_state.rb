module HadoopRunStateHelpers
  def hadoop_namenode
    node.run_state[:nodes].select do |n|
      n.role?("hadoop-namenode")
    end.first
  end

  def hadoop_jobtracker
    node.run_state[:nodes].select do |n|
      n.role?("hadoop-jobtracker")
    end.first
  end

  def hadoop_datanodes
    node.run_state[:nodes].select do |n|
      n.role?("hadoop-datanode")
    end
  end

  def hadoop_topology
    Hash[hadoop_datanodes.map do |n|
      [n, (n[:hadoop][:rack_id] || '/default/rack')]
    end]
  end
end

include HadoopRunStateHelpers

class Hadoop
  class Recipe
    include HadoopRunStateHelpers
  end

  class Node
    include HadoopRunStateHelpers
  end

  class Resource
    include HadoopRunStateHelpers
  end
end
