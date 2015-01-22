module ElasticsearchHelpers
  def elasticsearch_version
    @elasticsearch_version ||= mvn_project_version("/var/app/elasticsearch/current")
  end

  def elasticsearch_nodes(cluster_name = node.cluster_name)
    node.nodes.cluster(cluster_name).role("elasticsearch")
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
