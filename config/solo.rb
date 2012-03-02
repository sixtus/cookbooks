cwd = File.expand_path(File.join(File.dirname(__FILE__), ".."))

cookbook_path [
  "#{cwd}/cookbooks",
  "#{cwd}/site-cookbooks",
]

role_path "#{cwd}/roles"

if Process.euid == 0
  chef_root = "/var/lib/chef"
else
  chef_root = File.expand_path("~/.chef")
end

sandbox_path "#{chef_root}/sandboxes"
file_cache_path "#{chef_root}/cache/files"
file_backup_path "#{chef_root}/backup"

cache_options({
  :path => "#{chef_root}/cache/checksums",
  :skip_expires => true
})

verbose_logging false
