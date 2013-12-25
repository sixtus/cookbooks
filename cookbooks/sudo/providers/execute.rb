use_inline_resources

action :run do
  nr = new_resource

  command = nr.command
  command = "cd '#{nr.cwd}' && #{command}" if nr.cwd

  execute "sudo-#{nr.name}" do
    user "root"
    command(%{su -l -c '#{command}' #{nr.user}})
    creates nr.creates if nr.creates
    path nr.path if nr.path
    returns nr.returns if nr.returns
    timeout nr.timeout if nr.timeout
    umask nr.umask if nr.umask
  end
end
