
[<host>:<ipc port>]
* The stanza name should be contain the host and the ipc port that the Hadoop cluster is running 
* Example: hadoop.example.com:8020

namenode_http_port = <int>
* The port in which the namenode is listening for HTTP requests 
* Defaults to: 50070

hadoop_home = <string>
* Path to the Hadoop command line utilities that the app should use when communicating with 
* this cluster. If set to the string "$HADOOP_HOME" the environment variable present while 
* starting splunk will be used
* Defaults to empty string

java_home = <string>
* Path to Java home to use when communicating with this cluster. If set to the string "$JAVA_HOME" 
* the environment variable present while starting splunk will be used
* Defaults to empty string

kerberos_principal = <string>
* Fully qualified name of the Kerberos principal to use when communicating with this cluster.
* Valid only if the cluster is kerberized and core-site.xml in the clusters directory for 
* this cluster ($SPLUNK_HOME/etc/apps/local/HadoopConnect/clusters/<host>_<ipc_port>/core-site.xml)
* is present and dictates that kerberos be used 
* Defaults to: empty string

kerberos_service_principal = <string>
* Fully qualified name of the Kerberos principal that the HDFS service is running as.
* This needs to be the same value as dfs.namenode.kerberos.principal in core-site.xml of your 
* Hadoop cluster.
* Defaults to: empty string


