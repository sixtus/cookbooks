#!/bin/bash

PKGDIR=/var/cache/mirror/zentoo/amd64/packages
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
  env PKGDIR=${PKGDIR} emaint -f binhost >/dev/null

) 9>/run/lock/${PROGRAM}.lock
