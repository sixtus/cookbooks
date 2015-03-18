if gentoo?
  package "app-misc/tmux"

elsif debian_based?
  package "tmux"

elsif mac_os_x?
  homebrew_package "tmux"

end

template "#{node[:script_path]}/tmux-vim-select-pane" do
  source "tmux-vim-select-pane.sh"
  mode "0755"
end

template node[:tmux][:configfile] do
  source "tmux.conf"
  mode "0644"
end

if !root?
  overridable_template "#{node[:homedir]}/.tmux.conf.local" do
    source "tmux.conf.local"
    cookbook "users"
    instance node[:current_user]
  end
end
