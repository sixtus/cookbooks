#!/bin/bash

CLASSPATH="$(echo /var/app/camus/current/target/camus-*-SNAPSHOT-shaded.jar):$(/var/app/hadoop2/current/bin/hadoop classpath)"
exec /usr/bin/java -cp $CLASSPATH com.linkedin.camus.etl.kafka.CamusJob -P /etc/camus/camus.properties
