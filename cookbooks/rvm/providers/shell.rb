include ChefUtils::RVM

def load_current_resource
  @rubie = normalize_ruby_string(select_ruby(new_resource.ruby_string))
  @gemset = select_gemset(new_resource.ruby_string)
  @ruby_string = @gemset.nil? ? @rubie : "#{@rubie}@#{@gemset}"
  @rvm_env = ::RVM::ChefUserEnvironment.new(new_resource.user)
end

action :run do
  unless env_exists?(@ruby_string)
    e = rvm_environment @ruby_string do
      user new_resource.user
      action :nothing
    end
    e.run_action(:create)
  end

  script_wrapper :run
end

private

##
# Wraps the script resource for RVM-dependent code.
#
# @param [Symbol] action to be performed with gem_package provider
def script_wrapper(exec_action)
  script_code = <<-CODE
    if [ -s "${HOME}/.rvm/scripts/rvm" ]; then
      source "${HOME}/.rvm/scripts/rvm"
    fi

    rvm use #{@ruby_string}

    #{new_resource.code}
  CODE

  s = bash new_resource.name do
    user new_resource.user

    environment({
      'USER' => new_resource.user,
      'HOME' => Etc.getpwnam(new_resource.user).dir,
      'RUBYOPT' => "",
    }.merge(new_resource.environment))

    code script_code
    creates new_resource.creates if new_resource.creates
    cwd new_resource.cwd if new_resource.cwd
    group new_resource.group if new_resource.group
    path new_resource.path if new_resource.path
    returns new_resource.returns if new_resource.returns
    timeout new_resource.timeout if new_resource.timeout
    umask new_resource.umask if new_resource.umask
    action :nothing
  end
  s.run_action(exec_action)
  new_resource.updated_by_last_action(true) if s.updated_by_last_action?
end
