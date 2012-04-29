package value_for_platform(
  "gentoo" => {"default" => "dev-vcs/git"},
  "mac_os_x" => {"default" => "git"}
)

template node[:git][:rcfile] do
  source "gitconfig"
  mode "0644"
end

cookbook_file node[:git][:exfile] do
  source "gitignore"
  mode "0644"
end

if solo? and not root?
  overridable_template "#{node[:homedir]}/.gitconfig.local" do
    source "gitconfig.local"
    namespace :user
    instance node[:current_user]
  end
end
