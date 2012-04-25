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

  {
    :auto_mkdir => "https://github.com/DataWraith/auto_mkdir",
    :closetag => "https://github.com/vim-scripts/closetag.vim",
    :coffee_script => "https://github.com/kchmck/vim-coffee-script",
    :endwise => "https://github.com/tpope/vim-endwise",
    :haml => "https://github.com/tpope/vim-haml",
    :javascript => "https://github.com/pangloss/vim-javascript",
    :matchit => "https://github.com/vim-scripts/matchit.zip",
    :ruby => "https://github.com/vim-ruby/vim-ruby",
  }.each do |name, repo|
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
