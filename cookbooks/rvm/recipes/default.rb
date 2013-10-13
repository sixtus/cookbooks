# install rvm api gem during chef compile phase
if gentoo?
  pkg = package "dev-ruby/rvm" do
    action :nothing
  end
  pkg.run_action(:upgrade)
  Gem.clear_paths
else
  chef_gem 'rvm' do
    action :install
    version '>= 1.11.3.8'
  end
end

require 'rvm'

create_rvm_shell_chef_wrapper
create_rvm_chef_user_environment

rvm_instance node[:current_user]
