case node[:platform]
when "gentoo"
  portage_package_use "app-editors/vim" do
    use %w(python ruby)
  end

  package "app-editors/vim"
  package "dev-util/ctags"

when "mac_os_x"
  package "macvim" do
    action :upgrade
    notifies :create, "ruby_block[macvim-to-app]", :immediately
  end

  package "ctags"

  ruby_block "macvim-to-app" do
    action :nothing
    block do
      installed_path = %x(brew --prefix macvim).chomp + "/MacVim.app"
      destination_path = "/Applications/MacVim.app"
      system("rsync -a --delete #{installed_path}/ #{destination_path}/")
    end
  end

  file "/usr/local/bin/vim" do
    content "#!/bin/sh\nexec /Applications/MacVim.app/Contents/MacOS/Vim $*"
    mode "0755"
  end
end

directory node[:vim][:rcdir] do
  mode "0755"
end

directory "#{node[:vim][:rcdir]}/autoload" do
  mode "0755"
end

cookbook_file "#{node[:vim][:rcdir]}/autoload/pathogen.vim" do
  source "pathogen.vim"
  mode "0644"
end

directory "#{node[:vim][:rcdir]}/bundle" do
  mode "0755"
end

template "#{node[:vim][:rcdir]}/cleanup_bundle" do
  source "cleanup_bundle.sh"
  mode "0755"
  variables :bundles => solo? ? node[:vim][:plugins].keys.map(&:to_s) : [:solarized, :powerline]
end

if solo?
  node[:vim][:plugins].each do |name, repo|
    next unless repo
    git "#{node[:vim][:rcdir]}/bundle/#{name}" do
      repository repo
      reference "master"
      action :sync
    end
  end
else
  remote_directory "#{node[:vim][:rcdir]}/bundle/solarized" do
    source "solarized"
    owner "root"
    group "root"
  end

  directory "#{node[:vim][:rcdir]}/bundle/solarized/.git" do
    action :delete
    recursive true
  end

  remote_directory "#{node[:vim][:rcdir]}/bundle/powerline" do
    source "powerline"
    owner "root"
    group "root"
  end

  directory "#{node[:vim][:rcdir]}/bundle/powerline/.git" do
    action :delete
    recursive true
  end
end

execute "vim-cleanup-bundles" do
  command "#{node[:vim][:rcdir]}/cleanup_bundle"
end

if solo? and not root?
  overridable_template "#{node[:homedir]}/.vimrc.local" do
    source "vimrc.local"
    namespace :user
    instance node[:current_user]
  end
end

template node[:vim][:rcfile] do
  source "vimrc"
  mode "0644"
end
