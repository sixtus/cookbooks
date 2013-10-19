module PostfixRunStateHelpers
  def postfix_networks
    node.run_state[:nodes].map do |n|
      n[:primary_ipaddress]
    end + node[:postfix][:mynetworks]
  end
end

include PostfixRunStateHelpers

class Postfix
  class Recipe
    include PostfixRunStateHelpers
  end

  class Node
    include PostfixRunStateHelpers
  end

  class Resource
    include PostfixRunStateHelpers
  end
end
