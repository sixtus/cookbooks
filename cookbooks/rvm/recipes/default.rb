chef_gem "rvm" do
  action :install
  options "--user-install" if !root?
  compile_time true
end

Gem.clear_paths

require "rvm"

create_rvm_shell_chef_wrapper
create_rvm_chef_user_environment

if !root?
  rvm_instance node[:current_user]
end
