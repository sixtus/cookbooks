cwd = File.expand_path(File.join(File.dirname(__FILE__), ".."))

cookbook_path [
  "#{cwd}/cookbooks",
  "#{cwd}/site-cookbooks",
]

role_path "#{cwd}/roles"

chef_root = "/var/lib/chef"

sandbox_path "#{chef_root}/sandboxes"
file_cache_path "#{chef_root}/cache/files"
file_backup_path "#{chef_root}/backup"

cache_options({
  :path => "#{chef_root}/cache/checksums",
  :skip_expires => true
})

verbose_logging false
