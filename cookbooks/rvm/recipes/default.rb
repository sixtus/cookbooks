# this looks a little bit silly, but we need to ensure that the rvm gem is
# installed properly, even for non-root chef-solo users which are not using
# rvm/bundler (yet).
if gentoo?
  # portage package provider will take care of using sudo
  package "dev-ruby/rvm" do
    action :nothing
  end.run_action(:upgrade)
elsif debian_based?
  execute "sudo -H gem install rvm" do
    action :nothing
  end.run_action(:run)
else
  chef_gem 'rvm' do
    action :install
    version '>= 1.11.3.8'
  end
end

Gem.clear_paths

require 'rvm'

create_rvm_shell_chef_wrapper
create_rvm_chef_user_environment

if !root?
  rvm_instance node[:current_user]
end
