chef_repo_path File.expand_path(File.join(File.dirname(__FILE__), ".."))

if Process.euid == 0
  chef_root = "/var/lib/chef"
else
  chef_root = File.expand_path("~/.chef")
end

cookbook_path [
  "#{chef_repo_path}/cookbooks",
  "#{chef_repo_path}/site-cookbooks",
]

syntax_check_cache_path "#{chef_root}/cache/checksums"
file_cache_path "#{chef_root}/cache/files"
file_backup_path "#{chef_root}/backup"

Ohai::Config[:plugin_path] = ["#{chef_repo_path}/.ohai/plugins"]
