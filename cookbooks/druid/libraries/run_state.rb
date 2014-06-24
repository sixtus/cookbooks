module DruidHelpers
  def druid_version
    @druid_version ||= %x{cd /var/app/druid/current && /usr/bin/mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate -Dexpression=project.version | grep -v '\\[' | grep -v Download}.strip
  end
end

include DruidHelpers

class Chef
  class Recipe
    include DruidHelpers
  end

  class Node
    include DruidHelpers
  end

  class Resource
    include DruidHelpers
  end
end
