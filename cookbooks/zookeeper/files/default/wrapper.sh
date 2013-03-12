#!/bin/bash

# we need this wrapper since systemd does not support shell magic in EnvironmentFile
source /etc/conf.d/zookeeper

exec /usr/bin/java $JVM_OPTS -cp $CLASSPATH $MAIN $CONFIG
