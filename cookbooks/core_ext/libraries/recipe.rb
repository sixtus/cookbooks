class Chef
  class Recipe
    def solo?
      Chef::Config[:solo]
    end

    def root?
      Process.euid == 0
    end
  end
end
