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
		_sc $1 $2
	else
		/etc/init.d/$2 $1
	fi
}

_service "$@"
