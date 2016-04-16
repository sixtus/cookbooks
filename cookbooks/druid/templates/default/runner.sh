#!/bin/bash

# common JVM options
JVM_OPTS=""
JVM_OPTS+=" -server -d64"
JVM_OPTS+=" -Xmx<%= node[:druid][@service][:mx] %>m"
JVM_OPTS+=" -XX:MaxDirectMemorySize=<%= node[:druid][@service][:dm] %>m"
JVM_OPTS+=" -XX:+UseCompressedOops"
JVM_OPTS+=" -XX:+UseParNewGC"
JVM_OPTS+=" -XX:+UseConcMarkSweepGC"
JVM_OPTS+=" -XX:+CMSClassUnloadingEnabled"
JVM_OPTS+=" -XX:+CMSScavengeBeforeRemark"
JVM_OPTS+=" -XX:+DisableExplicitGC"
JVM_OPTS+=" -Duser.timezone=UTC"
JVM_OPTS+=" -Dfile.encoding=UTF-8"
JVM_OPTS+=" -Dlog4j.configuration=file:///var/app/druid/config/log4j.properties"
JVM_OPTS+=" -Djava.io.tmpdir=/var/app/druid/storage/tmp"
JVM_OPTS+=" -Dcom.sun.management.jmxremote.port=<%= node[:druid][@service][:port] + 10000 %>"
JVM_OPTS+=" -Dcom.sun.management.jmxremote.authenticate=false"
JVM_OPTS+=" -Dcom.sun.management.jmxremote.ssl=false"

# build the classpath - use node[:druid][:extensions] for more
CLASSPATH="/var/app/druid/config/_common:/var/app/druid/config/<%= @service %>"
CLASSPATH+=":/var/app/druid/postgresql.jar"
CLASSPATH+=":$(/usr/bin/find /var/app/druid/current/services/target/*selfcontained.jar)"

# add hadoop if it exists
if [ -x /var/app/hadoop2/current/bin/hadoop ]; then
  CLASSPATH+=":$(/var/app/hadoop2/current/bin/hadoop classpath)"
fi

exec /usr/bin/java $JVM_OPTS -cp $CLASSPATH io.druid.cli.Main server <%= @service %>
