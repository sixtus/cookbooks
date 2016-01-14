#!/bin/bash

DAEMON=${1:-postgresql@9.4}

function psql_get {
  psql -U postgres -t -P format=unaligned -c "$1"
}

systemctl status $DAEMON > /dev/null
if [[ $? -eq 0 ]]; then
  if [[ $( psql_get "SELECT pg_is_in_recovery();" ) == "f" ]]; then
    exit 0
  fi
fi

exit 2
