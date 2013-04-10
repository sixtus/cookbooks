action :run do
  s = execute "sudo-#{new_resource.name}" do
    command new_resource.command
    user "root"

    command %{su -l -c '#{new_resource.command}' #{new_resource.user}}

    creates new_resource.creates if new_resource.creates
    cwd new_resource.cwd if new_resource.cwd
    group new_resource.group if new_resource.group
    path new_resource.path if new_resource.path
    returns new_resource.returns if new_resource.returns
    timeout new_resource.timeout if new_resource.timeout
    umask new_resource.umask if new_resource.umask
    action :nothing
  end
  s.run_action(:run)
  new_resource.updated_by_last_action(true) if s.updated_by_last_action?
end
