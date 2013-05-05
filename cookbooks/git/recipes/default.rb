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
  remote_file "#{node[:homedir]}/bin/hub" do
    source "http://defunkt.io/hub/standalone"
    checksum "d1b6ced5c012d924d226bb14631fe58218ed0ad9561b181aff4c1a1d97996c29"
    mode "0755"
  end

  overridable_template "#{node[:homedir]}/.gitconfig.local" do
    source "gitconfig.local"
    namespace :user
    instance node[:current_user]
  end
end
