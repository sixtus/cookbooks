module SystemdHelpers
  def systemd_running?
    File.read("/proc/1/cmdline") =~ /systemd/
  end
end

include SystemdHelpers

class Chef
  class Recipe
    include SystemdHelpers
  end

  class Node
    include SystemdHelpers
  end

  class Resource
    include SystemdHelpers
  end
end
