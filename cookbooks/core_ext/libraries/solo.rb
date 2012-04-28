module SoloHelpers
  def solo?
    Chef::Config[:solo]
  end

  def root?
    Process.euid == 0
  end
end

include SoloHelpers

class Chef
  class Recipe
    include SoloHelpers
  end
end
