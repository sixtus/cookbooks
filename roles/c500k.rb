# see http://lowlatencyweb.wordpress.com/2012/03/20/500000-requestssec-modern-http-servers-are-fast/
description "Mixin for servers that need to handle huge amounts of connections"

default_attributes({
  :nginx => {
    :worker_connections => "16384",
    :fastcgi_buffers => 4096,
    :client_body_timeout => 10,
    :client_header_timeout => 10,
    :keepalive_timeout => 15,
    :send_timeout => 10,
  },

  # you should be _very_ careful when touching these
  :sysctl => {
    :net => {
      :core => {
        :somaxconn => 65536,
      },

      :ipv4 => {
        :ip_local_port_range => "2048 64512",
        :tcp_fin_timeout => 10,
        :tcp_max_syn_backlog => 65536,
        :tcp_syncookies => 0,
        :tcp_tw_recycle => 1,
        :tcp_tw_reuse => 1,
        :tcp_window_scaling => 0,
        :tcp_timestamps => 0,
      },

      :netfilter => {
        :nf_conntrack_max => "4194304",
      },
    },
  },
})
