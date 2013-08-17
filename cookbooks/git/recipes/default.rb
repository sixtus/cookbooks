case node[:platform]
when "gentoo"
  package "dev-vcs/git"

  if node[:portage][:repo] == "zentoo"
    package "dev-vcs/git-extras"
  end

when "debian"
  package "git"

when "mac_os_x"
  package "git"
  package "git-extras"

end

template node[:git][:rcfile] do
  source "gitconfig"
  mode "0644"
end

cookbook_file node[:git][:exfile] do
  source "gitignore"
  mode "0644"
end

if solo? and not root?
  cookbook_file "#{node[:homedir]}/bin/update-github-org" do
    source "update-github-org"
    mode "0755"
  end

  remote_file "#{node[:homedir]}/bin/hub" do
    source "http://hub.github.com/standalone"
    checksum "6094d00f1e10eb6713102b8766d6aef6b7fadf30b9ae2220851fa28e17d4017f"
    mode "0755"
  end

  overridable_template "#{node[:homedir]}/.gitconfig.local" do
    source "gitconfig.local"
    namespace :user
    instance node[:current_user]
  end
end
