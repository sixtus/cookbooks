include ChefUtils::RVM

def load_current_resource
  @rubie = normalize_ruby_string(select_ruby(new_resource.ruby_string))
  @gemset = select_gemset(new_resource.ruby_string)
  @ruby_string = @gemset.nil? ? @rubie : "#{@rubie}@#{@gemset}"
  @rvm_env = ::RVM::ChefUserEnvironment.new(new_resource.user)
end

action :create do
  next if skip_ruby?

  unless env_exists?(@ruby_string)
    e = rvm_environment @ruby_string do
      user new_resource.user
      action :nothing
    end
    e.run_action(:create)
  end

  Chef::Log.info("rvm_default_ruby[#{new_resource.name}] setting #{@ruby_string} as default for user #{new_resource.user}")
  @rvm_env.rvm(:use, @ruby_string, :default => true)
  new_resource.updated_by_last_action(true)
end

private

def skip_ruby?
  if ruby_default?(@ruby_string)
    Chef::Log.debug("rvm_default_ruby[#{new_resource.name}] #{@ruby_string} is already default for user #{new_resource.user}")
    true
  else
    false
  end
end
