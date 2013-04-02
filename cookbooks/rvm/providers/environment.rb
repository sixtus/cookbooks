include ChefUtils::RVM

def load_current_resource
  @rubie = normalize_ruby_string(select_ruby(new_resource.ruby_string))
  @gemset = select_gemset(new_resource.ruby_string)
  @ruby_string = @gemset.nil? ? @rubie : "#{@rubie}@#{@gemset}"
  @rvm_env = ::RVM::ChefUserEnvironment.new(new_resource.user)
end

action :create do
  if @gemset
    gemset_resource :create
  else
    ruby_resource :install
  end
end

private

def gemset_resource(exec_action)
  unless gemset_exists?(:ruby => @rubie, :gemset => @gemset)
    r = rvm_gemset @ruby_string do
      user new_resource.user
      action :nothing
    end
    r.run_action(exec_action)
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end
end

def ruby_resource(exec_action)
  unless ruby_installed?(@rubie)
    r = rvm_ruby @rubie do
      user new_resource.user
      action :nothing
    end
    r.run_action(exec_action)
    new_resource.updated_by_last_action(true) if r.updated_by_last_action?
  end
end
