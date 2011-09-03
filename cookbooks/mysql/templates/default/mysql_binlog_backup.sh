#!/bin/bash

PROGRAM=${0##*/}
LOG_FACILITY="local1"

exec 1> >(logger -i -p "${LOG_FACILITY}.info" -t "${PROGRAM}")
exec 2> >(logger -i -p "${LOG_FACILITY}.error" -t "${PROGRAM}")

(
  flock -n 9 || exit 1

<% if node[:mysql][:backup][:mode] == "stream" %>
  ssh <%= node[:mysql][:backup][:stream][:host] %> \
    "mkdir -p <%= node[:mysql][:backup][:stream][:dir] %>/$(hostname -f)/"

  rsync -avz /var/lib/mysql/mysql-bin.* \
    <%= node[:mysql][:backup][:stream][:host] %>:<%= node[:mysql][:backup][:stream][:dir] %>/$(hostname -f)/
<% else %>
  lftp -c "open backup; mkdir $(hostname -f)"
  lftp -c "open backup; mkdir $(hostname -f)/mysql"
  lftp -c "open backup; mput -c -O $(hostname -f)/mysql /var/lib/mysql/mysql-bin.*"
<% end %>

) 9>/var/lock/${PROGRAM}.lock
