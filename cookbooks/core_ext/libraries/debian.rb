module DebianHelpers
  def debian?
    %w(debian ubuntu).include?(node[:platform])
  end
end

include DebianHelpers

class Chef
  class Recipe
    include DebianHelpers
  end

  class Node
    include DebianHelpers
  end

  class Resource
    include DebianHelpers
  end
end
