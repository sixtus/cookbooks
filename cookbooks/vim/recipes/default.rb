if gentoo?
  portage_package_use "app-editors/vim" do
    use %w(python ruby)
  end

  package "app-editors/vim"
  package "dev-util/ctags"

elsif debian_based?
  package "vim"
  package "exuberant-ctags"

elsif mac_os_x?
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
    action :delete
  end
end

directory node[:vim][:rcdir] do
  mode "0755"
end

file "#{node[:vim][:rcdir]}/autoload/pathogen.vim" do
  action :delete
end

file "#{node[:vim][:rcdir]}/cleanup_bundle" do
  action :delete
end

if root?
  directory "#{node[:vim][:rcdir]}/bundle" do
    action :delete
    recursive true
  end
else
  git "#{node[:vim][:rcdir]}/bundle/neobundle.vim" do
    repository "https://github.com/Shougo/neobundle.vim"
    reference "master"
    action :checkout
  end

  overridable_template "#{node[:homedir]}/.vimrc.local" do
    source "vimrc.local"
    cookbook "users"
    instance node[:current_user]
  end
end

template node[:vim][:rcfile] do
  source "vimrc"
  mode "0644"
end
