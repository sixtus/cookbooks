#!/bin/bash

ipaddress=$(ip addr show dev eth0 | grep 'inet .*global' | awk '{ print $2 }')
gateway=$(ip route list | grep default | head -n1 | awk '{ print $3 }')

cat > /etc/systemd/network/default.network <<EOF
[Match]
Name=eth0

[Network]
Address=${ipaddress}
Gateway=${gateway}
EOF

ip2=$(echo ${ipaddress} | awk -F/ '{ print $1 }' | awk -F. '{ print $2 }')
ip3=$(echo ${ipaddress} | awk -F/ '{ print $1 }' | awk -F. '{ print $3 }')
ip4=$(echo ${ipaddress} | awk -F/ '{ print $1 }' | awk -F. '{ print $4 }')
local_ipaddress=10.${ip2}.${ip3}.${ip4}

cat > /etc/systemd/network/private.network <<EOF
[Match]
Name=eth1

[Network]
Address=${local_ipaddress}/8
EOF

if [[ -e /etc/netctl/eth0 ]]; then
	netctl disable eth0
	rm -f /etc/netctl/eth0
fi

ip addr flush eth1

systemctl daemon-reload
systemctl restart systemd-networkd
