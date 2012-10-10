# http://lowlatencyweb.wordpress.com/2012/03/20/500000-requestssec-modern-http-servers-are-fast/
# http://www.lognormal.com/blog/2012/09/27/linux-tcpip-tuning/

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
        :ip_local_port_range => "2048 65535",
        :tcp_fin_timeout => 10,
        :tcp_max_syn_backlog => 65536,
        :tcp_syncookies => 0,
        :tcp_tw_recycle => 1,
        :tcp_tw_reuse => 1,
        :tcp_window_scaling => 0,
        :tcp_timestamps => 0,
      },

      :netfilter => {
        :nf_conntrack_max => 4194304,
        :nf_conntrack_tcp_timeout_time_wait => 5,
        :nf_conntrack_tcp_timeout_established => 600,
      },
    },
  },
})
