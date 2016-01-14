default[:consul][:version] = "0.6.0"
default[:consul][:encrypt] = "DrpzTIcZOBoVvlJ9jcwD/g=="
default[:consul][:bind_addr] = node[:ipaddress]
default[:consul][:bootstrap_expect] = 3

default[:consul][:envconsul][:version] = "0.6.0"
default[:consul][:template][:version] = "0.12.0"

default[:consul][:dnsmasq][:repository] = "https://github.com/liquidm/dnsmasq.git"
default[:consul][:dnsmasq][:version] = "production"

default[:consul][:consulcli][:repository] = "https://github.com/liquidm/consul-cli.git"
default[:consul][:consulcli][:revision] = "production"
