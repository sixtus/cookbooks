if gentoo?
  package "dev-vcs/git"
  if zentoo?
    package "dev-vcs/git-extras"
    package "dev-vcs/hub"
  end
elsif debian_based?
  package "git"
elsif mac_os_x?
  homebrew_package "git"
  homebrew_package "git-extras"
  homebrew_package "hub"
end

template node[:git][:rcfile] do
  source "gitconfig"
  mode "0644"
end

cookbook_file node[:git][:exfile] do
  source "gitignore"
  mode "0644"
end

if !root?
  cookbook_file "#{node[:homedir]}/bin/update-github-org" do
    source "update-github-org"
    mode "0755"
  end

  file "#{node[:homedir]}/bin/hub" do
    action :delete
  end

  overridable_template "#{node[:homedir]}/.gitconfig.local" do
    source "gitconfig.local"
    cookbook "users"
    instance node[:current_user]
  end
end
