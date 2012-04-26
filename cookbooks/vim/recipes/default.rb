if platform?("mac_os_x")
  package "macvim" do
    action :upgrade
    notifies :create, "ruby_block[macvim-to-app]"
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
else
  portage_package_use "app-editors/vim" do
    use %w(ruby)
  end

  package "app-editors/vim"
  package "dev-util/ctags"
end

directory node[:vim][:rcdir] do
  mode "0755"
end

if solo? and not root?
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

  node[:vim][:plugins].each do |name, repo|
    next unless repo
    git "#{node[:vim][:rcdir]}/bundle/#{name}" do
      repository repo
      reference "master"
      action :sync
    end
  end

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
