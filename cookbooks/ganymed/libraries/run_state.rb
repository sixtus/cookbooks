module GanymedRunStateHelpers
  def ganymed?
    root? # for now we always deploy ganymed in root mode
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
