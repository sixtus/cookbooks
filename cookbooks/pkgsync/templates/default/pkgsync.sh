#!/bin/bash

PROGRAM=${0##*/}
LOG_FACILITY="local1"

exec 1> >(logger -i -p "${LOG_FACILITY}.info" -t "${PROGRAM}")
exec 2> >(logger -i -p "${LOG_FACILITY}.error" -t "${PROGRAM}")

PKGDIR=/usr/portage/packages
REMOTES="<%= @clients.map { |c| c[:ipaddress] }.join("\n") %>"

rsync() {
	/usr/bin/timeout --kill=1h 30m \
		/usr/bin/rsync --password-file /etc/pkgsync.secret "$@"
}

(
	flock -n 9 || exit 1

	# pull new packages
	for remote in ${REMOTES}; do
		rsync -au pkgsync@${remote}::pkgsync/ ${PKGDIR}/
	done

	# make sure these exist
	mkdir -p /usr/portage/packages/{amd64,x86}

	# delete old packages
	PKGDIR=/usr/portage/packages/amd64 /usr/bin/eclean --quiet packages
	PKGDIR=/usr/portage/packages/x86 /usr/bin/eclean --quiet packages

	# push changed packages
	for remote in ${REMOTES}; do
		rsync -a --delete ${PKGDIR}/ pkgsync@${remote}::pkgsync/
	done

) 9>/var/lock/${PROGRAM}.lock
