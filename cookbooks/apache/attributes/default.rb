default[:apache][:apr_util][:use] = Array.new

default[:apache][:mpm] = "prefork"

default[:apache][:modules] = %w(actions alias auth_basic authn_default
authn_file authz_default authz_groupfile authz_host authz_user autoindex cgi
cgid deflate dir env expires filter headers info log_config mime mime_magic
proxy rewrite setenvif status)

default[:apache][:default_redirect] = nil
default[:apache][:ssl][:enabled] = false
default[:apache][:error_log] = "syslog:daemon"
default[:apache][:php][:max_children] = "4"
