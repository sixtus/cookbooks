include ChefUtils::RVM

def load_current_resource
  if new_resource.ruby_string
    @rubie = normalize_ruby_string(select_ruby(new_resource.ruby_string))
    @gemset = new_resource.gemset
  else
    @rubie = normalize_ruby_string(select_ruby(new_resource.gemset))
    @gemset = select_gemset(new_resource.gemset)
  end
  @ruby_string = "#{@rubie}@#{@gemset}"
  @rvm_env = ::RVM::ChefUserEnvironment.new(new_resource.user)
end

action :create do
  unless ruby_installed?(@rubie)
    r = rvm_ruby @rubie do
      user new_resource.user
      action :nothing
    end
    r.run_action(:install)
  end

  if gemset_exists?(:ruby => @rubie, :gemset => @gemset)
    Chef::Log.debug("rvm_gemset[#{new_resource.name}] #{@ruby_string} already exists for user #{new_resource.user}")
  else
    Chef::Log.info("rvm_gemset[#{new_resource.name}] creating #{@ruby_string} for user #{new_resource.user}")

    @rvm_env.use(@rubie)

    if @rvm_env.gemset_create(@gemset)
      update_installed_gemsets(@rubie)
      Chef::Log.info("rvm_gemset[#{new_resource.name}] created #{@ruby_string} for user #{new_resource.user}")
    else
      raise "rvm_gemset[#{new_resource.name}] failed to create #{@ruby_string} for user #{new_resource.user}"
    end

    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  if gemset_exists?(:ruby => @rubie, :gemset => @gemset)
    Chef::Log.info("rvm_gemset[#{new_resource.name}] deleting #{@ruby_string} for user #{new_resource.user}")

    @rvm_env.use @rubie
    if @rvm_env.gemset_delete @gemset
      update_installed_gemsets(@rubie)
      Chef::Log.info("rvm_gemset[#{new_resource.name}] deleted #{@ruby_string} for user #{new_resource.user}")
      new_resource.updated_by_last_action(true)
    else
      raise "rvm_gemset[#{new_resource.name}] failed to delete #{@ruby_string} for user #{new_resource.user}"
    end
  else
    Chef::Log.debug("rvm_gemset[#{new_resource.name}] #{@ruby_string} does not exist for user #{new_resource.user}")
  end
end

action :empty do
  if gemset_exists?(:ruby => @rubie, :gemset => @gemset)
    Chef::Log.info("rvm_gemset[#{new_resource.name}] emptying #{@ruby_string} for user #{new_resource.user}")

    @rvm_env.use @ruby_string
    if @rvm_env.gemset_empty
      update_installed_gemsets(@rubie)
      Chef::Log.info("rvm_gemset[#{new_resource.name}] emptied #{@ruby_string} for user #{new_resource.user}")
      new_resource.updated_by_last_action(true)
    else
      raise "rvm_gemset[#{new_resource.name}] failed to empty #{@ruby_string} for user #{new_resource.user}"
    end
  else
    Chef::Log.debug("rvm_gemset[#{new_resource.name}] #{@ruby_string} does not exist for user #{new_resource.user}")
  end
end

action :update do
  Chef::Log.info("rvm_gemset[#{new_resource.name}] updating #{@ruby_string} for user #{new_resource.user}")

  unless gemset_exists?(:ruby => @rubie, :gemset => @gemset)
    c = rvm_gemset @ruby_string do
      user new_resource.user
      action :nothing
    end
    c.run_action(:create)
  end

  @rvm_env.use(@ruby_string)

  if @rvm_env.gemset_update
    update_installed_gemsets(@rubie)
    Chef::Log.info("rvm_gemset[#{new_resource.name}] updated #{@ruby_string} for user #{new_resource.user}")
    new_resource.updated_by_last_action(true)
  else
    raise "rvm_gemset[#{new_resource.name}] failed to update #{@ruby_string} for user #{new_resource.user}"
  end
end
