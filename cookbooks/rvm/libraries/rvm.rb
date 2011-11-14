module ChefUtils
  module RVM
    include ChefUtils::Account

    def infer_vars(user, version = nil)
      user = get_user(user)
      path = user[:name] == "root" ? "/usr/local/rvm" : "#{user[:dir]}/.rvm"
      rvmrc = user[:name] == "root" ? "/etc/rvmrc" : "#{user[:dir]}/.rvmrc"

      return {
        :user => user[:name],
        :group => user[:group][:name],
        :homedir => user[:dir],
        :path => path,
        :rvmrc => rvmrc,
        :version => version,
      }
    end
  end
end
