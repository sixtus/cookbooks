#!/bin/bash

PROGRAM=${0##*/}
LOG_FACILITY="local1"

exec 1> >(logger -i -p "${LOG_FACILITY}.info" -t "${PROGRAM}")
exec 2> >(logger -i -p "${LOG_FACILITY}.error" -t "${PROGRAM}")

(
  flock -n 9 || exit 1

  DATE=$(date +%Y%m%d)

  tmpdir=$(mktemp -d)

  mongodump -o ${tmpdir} || exit 1
  tar czf <%= node[:mongodb][:backup][:dir] %>/mongodump_full_${DATE}.tar.gz -C ${tmpdir} .

  lftp -c "open backup; mkdir $(hostname -f)" &>/dev/null
  lftp -c "open backup; mkdir $(hostname -f)/mongodb" &>/dev/null
  lftp -c "open backup; put -O $(hostname -f)/mongodb <%= node[:mongodb][:backup][:dir] %>/mongodump_full_${DATE}.tar.gz"

) 9>/var/lock/${PROGRAM}.lock
