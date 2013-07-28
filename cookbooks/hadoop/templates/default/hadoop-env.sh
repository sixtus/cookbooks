# Set Hadoop-specific environment variables here.

# The java implementation to use.
export JAVA_HOME=/etc/java-config-2/current-system-vm

# The maximum amount of heap to use, in MB.
export HADOOP_HEAPSIZE=8192

# Extra Java runtime options.
export HADOOP_OPTS=-server

# Command specific options appended to HADOOP_OPTS when specified
JMX_OPTS="-Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
export HADOOP_NAMENODE_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=17001 $HADOOP_NAMENODE_OPTS"
export HADOOP_SECONDARYNAMENODE_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=17002 $HADOOP_SECONDARYNAMENODE_OPTS"
export HADOOP_DATANODE_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=17003 $HADOOP_DATANODE_OPTS"
export HADOOP_BALANCER_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=17004 $HADOOP_BALANCER_OPTS"
export HADOOP_JOBTRACKER_OPTS="$JMX_OPTS -Dcom.sun.management.jmxremote.port=17005 $HADOOP_JOBTRACKER_OPTS"

# Where log files are stored.
export HADOOP_ROOT_LOGGER=INFO,DRFA
export HADOOP_LOG_DIR=/var/log/hadoop

# File naming remote slave hosts.  $HADOOP_HOME/conf/slaves by default.
# export HADOOP_SLAVES=${HADOOP_HOME}/conf/slaves

# A string representing this instance of hadoop. $USER by default.
# export HADOOP_IDENT_STRING=$USER

# The scheduling priority for daemon processes.  See 'man nice'.
# export HADOOP_NICENESS=10
