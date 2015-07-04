#!/bin/bash

if [[ -e /lxc/$1/rootfs/usr/lib/systemd/systemd ]]; then
	exec /usr/bin/lxc-start -F -n $1 -- /usr/lib/systemd/systemd
else
	exec /usr/bin/lxc-start -F -n $1
fi
