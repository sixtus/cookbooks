#!/bin/bash

ip=$(lxc-info -n $1 -iH)

if [[ -n "${ip}" ]]; then
	ip route del ${ip} dev lxcbr0 || :
	ip route add ${ip} dev lxcbr0
fi
