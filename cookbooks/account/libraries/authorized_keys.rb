module ChefUtils
  module Account
    def authorized_keys_for(users)
      users.map! { |u| u.to_sym }
      node.run_state[:users].select do |u|
        users.include?(u[:id].to_sym) and
        not u[:authorized_keys].empty?
      end.map do |u|
        u[:authorized_keys]
      end.flatten
    end
  end
end

class Chef::Recipe
  include ChefUtils::Account
end
