module OpenVPNRunStateHelpers
  def openvpn_nodes
    node.nodes.role("openvpn")
  end

  def openvpn_node
    openvpn_nodes.first
  end
end

include OpenVPNRunStateHelpers

class Chef
  class Recipe
    include OpenVPNRunStateHelpers
  end

  class Node
    include OpenVPNRunStateHelpers
  end

  class Resource
    include OpenVPNRunStateHelpers
  end
end
