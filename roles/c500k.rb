# http://lowlatencyweb.wordpress.com/2012/03/20/500000-requestssec-modern-http-servers-are-fast/
# http://www.lognormal.com/blog/2012/09/27/linux-tcpip-tuning/
# http://datatag.web.cern.ch/datatag/howto/tcp.html
# http://www.cdnplanet.com/blog/tune-tcp-initcwnd-for-optimum-performance/

description "Mixin for servers that need to handle huge amounts of connections"

default_attributes({
  :nginx => {
    :worker_processes => "8",
    :worker_connections => "16384",
    :tcp_nodelay => "off",
    :client_body_timeout => 10,
    :client_header_timeout => 10,
    :keepalive_timeout => 15,
    :send_timeout => 10,
    :fastcgi_buffers => 4096,
  },

  # you should be _very_ careful when touching these
  :sysctl => {
    :fs => {
      :file_max => 2097152, # 2^21
      :nr_open => 1048576, # 2^20
    },
    :net => {
      :core => {
        :somaxconn => 262144,
        :netdev_max_backlog => 65536,
        #:rmem_max => 16777216,
        #:wmem_max => 16777216,
      },

      :ipv4 => {
        :ip_local_port_range => "1024 65535",
        :tcp_fin_timeout => 3,
        :tcp_max_syn_backlog => 262144,
        :tcp_max_tw_buckets => 2097152,
        :tcp_sack => 1,
        :tcp_syncookies => 0,
        :tcp_timestamps => 0,
        :tcp_tw_recycle => 0,
        :tcp_tw_reuse => 1,
        :tcp_window_scaling => 0,
        #:tcp_rmem => "4096 87380 16777216",
        #:tcp_wmem => "4096 65536 16777216",
      },

      :netfilter => {
        :nf_conntrack_max => 4194304,
        :nf_conntrack_tcp_timeout_time_wait => 5,
        :nf_conntrack_tcp_timeout_established => 600,
      },
    },
  },
})
