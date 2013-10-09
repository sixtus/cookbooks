#!/bin/bash

PROGRAM=${0##*/}
LOG_FACILITY="local1"

exec 1> >(logger -i -p "${LOG_FACILITY}.info" -t "${PROGRAM}")
exec 2> >(logger -i -p "${LOG_FACILITY}.error" -t "${PROGRAM}")

(
  flock -n 9 || exit 1

  find <%= node[:mongodb][:backup][:dir] %> -mindepth 1 -maxdepth 1 -name '*.tar.gz' -type f -mtime +<%= node[:mongodb][:backup][:keep] %> | \
  while read file; do
    tarball=$(basename "${file}")
    lftp -c "open backup; rm $(hostname -f)/mongodb/${tarball}"
    rm -f "${file}"
  done

) 9>/run/lock/${PROGRAM}.lock
