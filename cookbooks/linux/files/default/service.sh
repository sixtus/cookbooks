#!/bin/bash

_systemd_running() {
	[[ $(</proc/1/cmdline) =~ systemd ]]
}

_sc() {
	if [[ $USER == "root" ]]; then
		systemctl $*
	else
		systemctl --user $*
	fi
}

_service() {
	if _systemd_running; then
		_sc $2 $1
	else
		rc-service $1 $2
	fi
}

if [[ $# -ne 2 ]]; then
	echo "Usage: service <name> <action>"
	exit 1
fi

_service "$@"
