module PlatformHelpers
  def php_extension_dir
    %x(#{node[:php][:php_config]} --extension-dir 2>/dev/null || :).chomp
  end
end

include PlatformHelpers

class Chef
  class Recipe
    include PlatformHelpers
  end

  class Node
    include PlatformHelpers
  end

  class Resource
    include PlatformHelpers
  end
end
