default[:php][:sapi] = %w(cli fpm)
default[:php][:use_flags] = []

default[:php][:default_use_flags] = %w(-*
  bcmath
  bzip2
  crypt
  ctype
  curl
  exif
  filter
  ftp
  gd
  hash
  iconv
  imap
  intl
  json
  mysql
  mysqli
  mysqlnd
  nls
  pcre
  pdo
  phar
  posix
  readline
  reflection
  session
  simplexml
  soap
  sockets
  spl
  sqlite
  ssl
  tokenizer
  truetype
  unicode
  xml
  xmlreader
  xmlwriter
  xslt
  zip
  zlib
)

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
default[:php][:memory_limit] = "-1"
default[:php][:post_max_size] = "32M"
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
default[:php][:upload][:max_filesize] = "32M"
default[:php][:upload][:tmp_dir] = "#{node[:php][:tmp_dir]}/uploads"

# paths
default[:php][:slot] = "5.5"
default[:php][:install_path] = "/usr/lib/php#{node[:php][:slot]}"
default[:php][:php_config] = "/usr/bin/php-config"

# create default fpm pool
default[:php][:fpm][:conf] = "/etc/php/fpm-php#{node[:php][:slot]}/php-fpm.conf"
default[:php][:fpm][:pools][:default] = {}
