require "securerandom"

module ChefUtils
  module RandomResource
    def rrand
      SecureRandom.hex(6)
    end
  end
end

class Chef::Recipe
  include ChefUtils::RandomResource
end
