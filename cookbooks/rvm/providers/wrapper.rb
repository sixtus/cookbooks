include ChefUtils::RVM

def load_current_resource
  @rubie = normalize_ruby_string(select_ruby(new_resource.ruby_string))
  @gemset = select_gemset(new_resource.ruby_string)
  @ruby_string = @gemset.nil? ? @rubie : "#{@rubie}@#{@gemset}"
  @rvm_env = ::RVM::ChefUserEnvironment.new(new_resource.user)

  if new_resource.binary.nil?
    @binaries = new_resource.binaries || []
  else
    @binaries = [ new_resource.binary ] || []
  end
end

action :create do
  unless env_exists?(@ruby_string)
    e = rvm_environment @ruby_string do
      user new_resource.user
      action :nothing
    end
    e.run_action(:create)
  end

  @rvm_env.use(@ruby_string)
  @binaries.each { |b| create_wrapper(b) }
end

private

def create_wrapper(bin)
  full_bin = "#{new_resource.prefix}_#{bin}"
  resource_name = "rvm_wrapper[#{full_bin}::#{@ruby_string}]"
  script = ::File.join(@rvm_env.config["rvm_path"], "bin", full_bin)

  if ::File.exists?(script)
    Chef::Log.debug("#{resource_name} already exists, so updating")
  else
    Chef::Log.info("#{resource_name} creating wrapper")
  end

  if @rvm_env.wrapper(@ruby_string, new_resource.prefix, bin)
    Chef::Log.debug("Creation/Update of #{resource_name} was successful.")
  else
    Chef::Log.warn("Failed to create/update #{resource_name}.")
  end
end
