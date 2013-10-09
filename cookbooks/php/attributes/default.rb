default[:php][:default_use_flags] = %w(-* bcmath bzip2 crypt ctype curl exif filter ftp gd hash iconv imap json mysql mysqli mysqlnd nls pcre pdo posix reflection session simplexml soap sockets spl sqlite3 ssl tokenizer truetype unicode xml zlib zip)
default[:php][:use_flags] = []
default[:php][:sapi] = %w(cli)

default[:php][:tmp_dir] = "/var/tmp/php"

# misc php settings
default[:php][:short_open_tag] = "On"
default[:php][:allow_call_time_pass_reference] = "Off"
default[:php][:display_errors] = "Off"
default[:php][:expose_php] = "Off"
default[:php][:magic_quotes_gpc] = "Off"
default[:php][:max_execution_time] = "30"
default[:php][:max_input_nesting_level] = "64"
default[:php][:max_input_time] = "60"
default[:php][:max_input_vars] = "1000"
default[:php][:memory_limit] = "128M"
default[:php][:post_max_size] = "8M"
default[:php][:realpath_cache_size] = "16k"
default[:php][:register_argc_argv] = "Off"
default[:php][:register_globals] = "Off"
default[:php][:register_long_arrays] = "Off"

# session settings
default[:php][:session][:auto_start] = "0"
default[:php][:session][:lifetime] = "60"
default[:php][:session][:save_path] = "#{node[:php][:tmp_dir]}/sessions"
default[:php][:session][:use_only_cookies] = "1"

# upload settings
default[:php][:upload][:max_filesize] = "2M"
default[:php][:upload][:tmp_dir] = "#{node[:php][:tmp_dir]}/uploads"

# slot support on gentoo
if node[:platform] == "gentoo"
  default[:php][:slot] = "5.3"
  default[:php][:install_path] = "/usr/lib/php#{node[:php][:slot]}"
  default[:php][:php_config] = "#{node[:php][:install_path]}/bin/php-config"
end

# create default fpm pool
default[:php][:fpm][:conf] = "/etc/php/fpm-php#{node[:php][:slot]}/php-fpm.conf"
default[:php][:fpm][:pools][:default] = {}

# infer extension dir
default[:php][:extension_dir] = %x(#{node[:php][:php_config]} --extension-dir).chomp rescue "/does/not/exist"

# xcache
default[:php][:xcache][:admin_enable_auth] = "Off"
default[:php][:xcache][:admin_pass] = ""
default[:php][:xcache][:cacher] = "On"
default[:php][:xcache][:count] = "2"
default[:php][:xcache][:size] = "64M"
default[:php][:xcache][:var_count] = node[:php][:xcache][:count]
default[:php][:xcache][:var_size] = "64M"
