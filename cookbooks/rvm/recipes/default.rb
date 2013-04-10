if root?
  # install rvm api gem during chef compile phase
  case node[:platform]
  when "gentoo"
    pkg = package "dev-ruby/rvm" do
      action :nothing
    end
    pkg.run_action(:install)
    Gem.clear_paths
  else
    chef_gem 'rvm' do
      action :install
      version '>= 1.11.3.6'
    end
  end

  require 'rvm'

  create_rvm_shell_chef_wrapper
  create_rvm_chef_user_environment
else
  %w(gem irb rvm).each do |file|
    template "#{node[:homedir]}/.#{file}rc" do
      source "#{file}rc"
      mode "0644"
    end
  end
end
