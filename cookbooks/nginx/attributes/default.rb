default[:nginx][:use_flags] = []

default[:nginx][:worker_processes] = node[:cpu][:total]
default[:nginx][:worker_connections] = "16384"

default[:nginx][:client_body_timeout] = 10
default[:nginx][:client_header_timeout] = 10
default[:nginx][:client_max_body_size] = "0"
default[:nginx][:keepalive_timeout] = 15
default[:nginx][:send_timeout] = 10

default[:nginx][:fastcgi_buffers] = 4096

default[:nginx][:php][:max_children] = "4"
