unless platform?("mac_os_x")
  package "app-editors/vim"
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
