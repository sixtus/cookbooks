module ZentooHelpers
  def zentoo?
    node[:portage][:repo] == "zentoo"
  end
end

include ZentooHelpers

class Chef
  class Recipe
    include ZentooHelpers
  end

  class Node
    include ZentooHelpers
  end

  class Resource
    include ZentooHelpers
  end
end
