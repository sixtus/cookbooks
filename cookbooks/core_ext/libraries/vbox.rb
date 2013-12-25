module VboxHelpers
  def vbox_guest?
    node[:virtualization][:system] == "vbox" and node[:virtualization][:role] == "guest"
  end

  def vagrant?
    vbox_guest? && node[:cluster][:name] == "vagrant"
  end
end

include VboxHelpers

class Chef
  class Recipe
    include VboxHelpers
  end

  class Node
    include VboxHelpers
  end

  class Resource
    include VboxHelpers
  end
end
