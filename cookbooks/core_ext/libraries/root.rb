module RootHelpers
  def root?
    Process.euid == 0
  end
end

include RootHelpers

class Chef
  class Recipe
    include RootHelpers
  end

  class Node
    include RootHelpers
  end

  class Resource
    include RootHelpers
  end
end
