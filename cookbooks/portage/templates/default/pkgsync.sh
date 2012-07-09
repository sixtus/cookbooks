#!/bin/bash

PROGRAM=${0##*/}
LOG_FACILITY="local1"

exec 1> >(logger -i -p "${LOG_FACILITY}.info" -t "${PROGRAM}")
exec 2> >(logger -i -p "${LOG_FACILITY}.error" -t "${PROGRAM}")

PKGDIR=/var/cache/portage/packages
REMOTES="<%= @clients.join("\n") %>"

rsync() {
	/usr/bin/timeout --kill=1h 30m \
		/usr/bin/rsync "$@"
}

(
	flock -n 9 || exit 1

	# pull new packages
	for remote in ${REMOTES}; do
		rsync -au ${remote}::portage-packages/ ${PKGDIR}/
	done

	# regenerate Packages files
	for arch in amd64 x86; do
		env PKGDIR=${PKGDIR}/${arch} emaint -f binhost >/dev/null
	done

) 9>/var/lock/${PROGRAM}.lock
