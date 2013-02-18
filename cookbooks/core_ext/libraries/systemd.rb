module SystemdHelpers
  def systemd_running?
    File.read("/proc/1/cmdline").chomp =~ /systemd/
  end

  def systemd?
    node[:systemd] and node[:systemd][:enabled]
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
