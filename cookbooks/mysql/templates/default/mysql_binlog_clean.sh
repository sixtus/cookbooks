#!/bin/bash

PROGRAM=${0##*/}
LOG_FACILITY="local1"

exec 1> >(logger -i -p "${LOG_FACILITY}.info" -t "${PROGRAM}")
exec 2> >(logger -i -p "${LOG_FACILITY}.error" -t "${PROGRAM}")

(
  flock -n 9 || exit 1

<% if node[:mysql][:backup][:mode] == "stream" %>
  ssh <%= node[:mysql][:backup][:stream][:host] %> \
    "find <%= node[:mysql][:backup][:stream][:dir] %>/$(hostname -f)/ -mindepth 1 -maxdepth 1 -name 'mysql-bin.*' -type f -mtime +<%= node[:mysql][:backup][:keep] %> -delete"
<% else %>
  find <%= node[:mysql][:backup][:copy][:dir] %> -mindepth 1 -maxdepth 1 -name 'mysql-bin.*' -type f -mtime +<%= node[:mysql][:backup][:keep] %> | \
  while read file; do
    binlog=$(basename "${file}")
    lftp -c "open backup; rm $(hostname -f)/mysql/${binlog}"
    rm -f "${file}"
  done
<% end %>

) 9>/run/lock/${PROGRAM}.lock
