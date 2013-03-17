#!/bin/bash

PROGRAM=${0##*/}
LOG_FACILITY="local1"

exec 1> >(logger -i -p "${LOG_FACILITY}.info" -t "${PROGRAM}")
exec 2> >(logger -i -p "${LOG_FACILITY}.error" -t "${PROGRAM}")

(
  flock -n 9 || exit 1

  DATE=$(date +%Y%m%d)

<% if node[:mysql][:backup][:mode] == "stream" %>
  ssh <%= node[:mysql][:backup][:stream][:host] %> \
    "mkdir -p <%= node[:mysql][:backup][:stream][:dir] %>/$(hostname -f)/"

  innobackupex --slave-info --stream=tar /var/lib/mysql | \
    gzip --fast | \
    ssh <%= node[:mysql][:backup][:stream][:host] %> \
      "cat > <%= node[:mysql][:backup][:stream][:dir] %>/$(hostname -f)/xtrabackup_full_${DATE}.tar.gz"
<% else %>
  innobackupex --slave-info --stream=tar /var/lib/mysql | \
    gzip --fast > <%= node[:mysql][:backup][:copy][:dir] %>/xtrabackup_full_${DATE}.tar.gz

  lftp -c "open backup; mkdir $(hostname -f)" &>/dev/null
  lftp -c "open backup; mkdir $(hostname -f)/mysql" &>/dev/null
  lftp -c "open backup; put -O $(hostname -f)/mysql <%= node[:mysql][:backup][:copy][:dir] %>/xtrabackup_full_${DATE}.tar.gz"
<% end %>

) 9>/run/lock/${PROGRAM}.lock
