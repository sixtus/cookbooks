module ChefUtils
  module RVM

    include ChefUtils::Account

    def infer_rvm_vars(user, version = nil)
      user = get_user(user)

      unless version
        ghresult = open('https://api.github.com/repos/wayneeseguin/rvm/tags').read
        latest = JSON::parse(ghresult).first['name']
        version = latest
      end

      return {
        :user => user[:name],
        :group => user[:group][:name],
        :homedir => user[:dir],
        :path => "#{user[:dir]}/.rvm",
        :rvmrc => "#{user[:dir]}/.rvmrc",
        :version => version,
      }
    end

    ##
    # Lists all installed RVM Rubies on the system.
    #
    # **Note** that these values are cached for lookup speed. To flush these
    # values and force an update, call #update_installed_rubies.
    #
    # @return [Array] the cached list of currently installed RVM Rubies
    def installed_rubies
      @installed_rubies ||= update_installed_rubies
    end

    ##
    # Updates the list of all installed RVM Rubies on the system
    #
    # @return [Array] the list of currently installed RVM Rubies
    def update_installed_rubies
      @installed_rubies = @rvm_env.list_strings
      @installed_rubies
    end

    ##
    # Determines whether or not the given Ruby is already installed
    #
    # @param [String, #to_s] the RVM Ruby string
    # @return [Boolean] is this Ruby installed?
    def ruby_installed?(rubie)
      ! installed_rubies.select { |r| r.end_with?(rubie) }.empty?
    end

    ##
    # Filters out any gemset declarations in an RVM Ruby string
    #
    # @param [String, #to_s] the RVM Ruby string
    # @return [String] the Ruby string, minus gemset
    def select_ruby(ruby_string)
      ruby_string.split('@').first
    end

    ##
    # Lists all gemsets for a given RVM Ruby.
    #
    # **Note** that these values are cached for lookup speed. To flush these
    # values and force an update, call #update_installed_gemsets.
    #
    # @param [String, #to_s] the RVM Ruby string
    # @return [Array] a cached list of gemset names
    def installed_gemsets(rubie)
      @installed_gemsets = Hash.new if @installed_gemsets.nil?
      @installed_gemsets[rubie] ||= update_installed_gemsets(rubie)
    end

    ##
    # Updates the list of all gemsets for a given RVM Ruby on the system
    #
    # @param [String, #to_s] the RVM Ruby string
    # @return [Array] the current list of gemsets
    def update_installed_gemsets(rubie)
      original_rubie = @rvm_env.environment_name
      @rvm_env.use(rubie)

      @installed_gemsets ||= {}
      @installed_gemsets[rubie] = @rvm_env.gemset_list
      @rvm_env.use original_rubie if original_rubie != rubie
      @installed_gemsets[rubie]
    end

    ##
    # Determines whether or not a gemset exists for a given Ruby
    #
    # @param [Hash] the options to query a gemset with
    # @option opts [String] :ruby the Ruby the query within
    # @option opts [String] :gemset the gemset to look for
    def gemset_exists?(opts={})
      return false if opts[:ruby].nil? || opts[:gemset].nil?
      return false unless ruby_installed?(opts[:ruby])
      installed_gemsets(opts[:ruby]).include?(opts[:gemset])
    end

    ##
    # Determines whether or not and ruby/gemset environment exists
    #
    # @param [String, #to_s] the fully qualified RVM ruby string
    # @return [Boolean] does this environment exist?
    def env_exists?(ruby_string)
      rubie = select_ruby(ruby_string)
      gemset = select_gemset(ruby_string)

      if gemset
        gemset_exists?(:ruby => rubie, :gemset => gemset)
      else
        ruby_installed?(rubie)
      end
    end

    ##
    # Fetches the current default Ruby string, potentially with gemset
    #
    # @return [String] the RVM Ruby string, nil if none is set
    def current_ruby_default
      @rvm_env.list_default
    end

    ##
    # Determines whether or not the given Ruby is the default one
    #
    # @param [String, #to_s] the RVM Ruby string
    # @return [Boolean] is this Ruby the default one?
    def ruby_default?(rubie)
      current_default = current_ruby_default

      if current_default.nil?
        if rubie == "system"
          return true
        else
          return false
        end
      end

      current_default.start_with?(rubie)
    end

    ##
    # Filters out any Ruby declaration in an RVM Ruby string
    #
    # @param [String, #to_s] the RVM Ruby string
    # @return [String] the gemset string, minus Ruby or nil if no gemset given
    def select_gemset(ruby_string)
      if ruby_string.include?('@')
        ruby_string.split('@').last
      else
        nil
      end
    end

    ##
    # Sanitizes a Ruby string so that it's more normalized.
    #
    # @param [String, #to_s] an RVM Ruby string
    # @param [String] a specific user RVM or nil for system-wide
    # @return [String] a fully qualified RVM Ruby string
    def normalize_ruby_string(ruby_string, user = new_resource.user)
      return "system" if ruby_string == "system"
      StringCache.fetch(ruby_string, user)
    end

  end
end
