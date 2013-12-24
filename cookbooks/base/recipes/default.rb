include_recipe "base::run_state"

# create script path
directory node[:script_path] do
  owner Process.euid
  mode "0755"
end

# load platform recipes
include_recipe "base::linux" if linux?
include_recipe "base::mac_os_x" if mac_os_x?
