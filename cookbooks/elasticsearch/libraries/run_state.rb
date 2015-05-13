module ElasticsearchHelpers
  def elasticsearch_version
    @elasticsearch_version ||= mvn_project_version("/var/app/elasticsearch/current")
  end

  def elasticsearch_nodes(cluster_name = nil)
    cluster_name ||= (node[:elasticsearch][:cluster] || node.cluster_name)
    node.nodes.role("elasticsearch").filter{|n| n[:elasticsearch][:cluster] == cluster_name }
  end

  def elasticsearch_masters(cluster_name = nil)
    elasticsearch_nodes(cluster_name).filter{|n| n[:elasticsearch][:master] == true }
  end

  def elasticsearch_heads(cluster_name = nil)
    cluster_name ||= (node[:elasticsearch][:journald][:cluster] || node.cluster_name)
    all_nodes = elasticsearch_nodes(cluster_name)
    search_nodes = all_nodes.filter{|n| n[:elasticsearch][:master] == false && n[:elasticsearch][:data] == false }

    if search_nodes.length > 0
      search_nodes
    else
      all_nodes
    end
  end
end

include ElasticsearchHelpers

class Chef
  class Recipe
    include ElasticsearchHelpers
  end

  class Node
    include ElasticsearchHelpers
  end

  class Resource
    include ElasticsearchHelpers
  end
end
