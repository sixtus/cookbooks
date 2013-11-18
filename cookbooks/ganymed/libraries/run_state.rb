module GanymedRunStateHelpers
  def ganymed?
    root? && gentoo?
  end
end

include GanymedRunStateHelpers

class Ganymed
  class Recipe
    include GanymedRunStateHelpers
  end

  class Node
    include GanymedRunStateHelpers
  end

  class Resource
    include GanymedRunStateHelpers
  end
end
