include_recipe "base::run_state"

# create script path
directory node[:script_path] do
  owner Process.euid
  mode "0755"
end

# load platform recipes
include_recipe "base::linux" if linux?
include_recipe "base::mac_os_x" if mac_os_x?

# load common recipes
include_recipe "bash"
include_recipe "git"
include_recipe "htop"
include_recipe "lftp"
include_recipe "python"
include_recipe "ssh"
include_recipe "tmux"
include_recipe "vim"
