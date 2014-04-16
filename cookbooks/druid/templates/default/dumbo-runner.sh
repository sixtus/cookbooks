#!/bin/bash

# Run in UTC
export TZ="/usr/share/zoneinfo/UTC"
export JRUBY_OPTS="-J-Xmx1g"
unset RUBYOPTS

source ~/.rvm/scripts/rvm

PATH+=":<%= node[:druid][:hadoop][:path] %>"

while true; do
  cd /var/app/dumbo/current || exit 1

  (
    flock -n 9 || exit 1
    ./dumbo.rb
  ) 9>/var/app/dumbo/run.lock

  # spawn hadoop
  for conf in /var/app/dumbo/*.druid; do
    /var/app/dumbo/bin/batch-druid-job.sh $conf &
    sleep 10
  done

  sleep 60
done
