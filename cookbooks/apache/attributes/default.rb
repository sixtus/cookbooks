default[:apache][:apr_util][:use] = []

default[:apache][:modules] = %w(actions alias auth_basic authn_default
authn_file authz_default authz_groupfile authz_host authz_user autoindex cgi
cgid deflate dir env expires filter headers info log_config mime mime_magic
negotiation proxy rewrite setenvif status unique_id)

# MPM configuration
default[:apache][:mpm] = "prefork"

default[:apache][:start_servers] = "5"
default[:apache][:max_clients] = "256"
default[:apache][:max_requests_per_child] = "10000"

# prefork, itk
default[:apache][:min_spare_servers] = "5"
default[:apache][:max_spare_servers] = "10"

# worker, event
default[:apache][:min_spare_threads] = "25"
default[:apache][:max_spare_threads] = "75"
default[:apache][:threads_per_child] = "25"

# peruser
default[:apache][:min_spare_processors] = "2"
default[:apache][:max_spare_processors] = "0"
default[:apache][:min_processors] = "2"
default[:apache][:max_processors] = "10"
default[:apache][:expire_timeout] = "1800"
default[:apache][:idle_timeout] = "300"
default[:apache][:min_multiplexers] = "5"
default[:apache][:max_multiplexers] = "10"
default[:apache][:multiplexer_idle_timeout] = "120"
default[:apache][:processor_wait_timeout] = "10"

default[:apache][:error_log] = "syslog:daemon"

default[:apache][:ssl][:enabled] = false

default[:apache][:php][:max_children] = "4"
