#!/bin/bash

# Run in UTC
export TZ="/usr/share/zoneinfo/UTC"
export JRUBY_OPTS="-J-Xmx4g"
unset RUBYOPTS

source ~/.rvm/scripts/rvm

export PATH=/var/app/hadoop2/current/bin:$PATH

while true; do
  cd /var/app/dumbo/current || exit 1

  (
    flock -n 9 || exit 1
    ./dumbo.rb
  ) 9>/var/app/dumbo/run.lock

  # spawn hadoop
  for spec in /var/app/dumbo/*.spec; do
    /var/app/dumbo/bin/batch $spec &
    sleep 10
  done

  sleep 60
done
