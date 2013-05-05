case node[:platform]
when "gentoo"
  package "app-misc/tmux"

when "debian"
  package "tmux"

when "mac_os_x"
  package "tmux"

end

template node[:tmux][:configfile] do
  source "tmux.conf"
  mode "0644"
end

if solo? and not root?
  overridable_template "#{node[:homedir]}/.tmux.conf.local" do
    source "tmux.conf.local"
    namespace :user
    instance node[:current_user]
  end
end
