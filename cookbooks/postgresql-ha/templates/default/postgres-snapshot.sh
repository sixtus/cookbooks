#!/bin/bash

HOUR=`/bin/date +%k`00

cd <%= node[:postgresql][:snapshot][:path] %>
/bin/rm -rf ${HOUR}
/bin/mkdir -p ${HOUR}
exec /usr/bin/pg_basebackup -D ${HOUR} --xlog-method=stream
