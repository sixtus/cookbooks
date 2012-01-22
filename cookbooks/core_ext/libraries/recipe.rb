class Chef
  class Recipe
    def solo?
      Chef::Config[:solo]
    end

    def root?
      node[:current_user] == "root"
    end
  end
end
