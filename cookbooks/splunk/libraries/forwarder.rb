module SplunkHelpers
  def splunk_forwarder?
    node.run_state[:splunk].any? && [
      node.role?("splunk-master"),
      node.role?("splunk-peer"),
      node.role?("splunk-search"),
      node.role?("splunk-server"),
    ].none?
  end
end

include SplunkHelpers

class Chef
  class Recipe
    include SplunkHelpers
  end

  class Node
    include SplunkHelpers
  end

  class Resource
    include SplunkHelpers
  end
end
