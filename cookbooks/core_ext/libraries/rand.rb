require "securerandom"

module RandomHelpers
  def rrand
    SecureRandom.hex(6)
  end
end

include RandomHelpers

class Chef
  class Recipe
    include RandomHelpers
  end

  class Node
    include RandomHelpers
  end

  class Resource
    include RandomHelpers
  end
end
