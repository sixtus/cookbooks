module GanymedRunStateHelpers
  def ganymed?
    root? && gentoo? && !vbox_guest?
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
