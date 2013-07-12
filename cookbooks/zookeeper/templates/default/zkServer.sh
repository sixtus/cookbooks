#!/bin/bash

# JVM options
JVM_OPTS="-Dcom.sun.management.jmxremote.port=17000 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"

# zookeeper files
MAIN="org.apache.zookeeper.server.quorum.QuorumPeerMain"
CONFIG="/opt/zookeeper/conf/zoo.cfg"

# build the classpath
INSTALL_DIR=/opt/zookeeper
CLASSPATH="${INSTALL_DIR}/conf:${CLASSPATH}"

for i in ${INSTALL_DIR}/zookeeper-*.jar; do
  CLASSPATH="${i}:${CLASSPATH}"
done

for i in ${INSTALL_DIR}/lib/*.jar; do
  CLASSPATH="${i}:${CLASSPATH}"
done

exec /usr/bin/java $JVM_OPTS -cp $CLASSPATH $MAIN $CONFIG
