module VserverHelpers
  def vserver_guest?
    node[:virtualization][:system] == "linux-vserver" and node[:virtualization][:role] == "guest"
  end
end

include VserverHelpers

class Chef
  class Recipe
    include VserverHelpers
  end

  class Node
    include VserverHelpers
  end

  class Resource
    include VserverHelpers
  end
end
