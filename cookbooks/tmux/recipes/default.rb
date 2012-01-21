package value_for_platform(
  "gentoo" => {"default" => "app-misc/tmux"},
  "mac_os_x" => {"default" => "tmux"}
)

cookbook_file node[:tmux][:configfile] do
  source "tmux.conf"
  mode "0644"
end
