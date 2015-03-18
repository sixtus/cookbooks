default[:hadoop2][:version] = "2.5.2"

default[:hadoop2][:hdfs][:cluster] = node.cluster_name
default[:hadoop2][:yarn][:cluster] = node.cluster_name
default[:hadoop2][:rack_id] = "/default-rack/#{node.cluster_name}"

default[:hadoop2][:tmp_dir] = "/var/tmp/hadoop2"
default[:hadoop2][:java_tmp] = "/var/tmp/java"

default[:hadoop2][:zookeeper][:cluster] = node.cluster_name

# http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.0.9.1/bk_installing_manually_book/content/rpm-chap1-11.html
mem_total = node[:memory][:total].to_i / 1024 / 1024 rescue 0.25

if mem_total <= 4
  min_container_size = 0.25
elsif mem_total <= 8
  min_container_size = 0.5
elsif mem_total <= 24
  min_container_size = 1
else
  min_container_size = 2
end

default[:hadoop2][:yarn][:containers] = [
  2 * node[:cpu][:total],
  mem_total / min_container_size,
].min

default[:hadoop2][:yarn][:mem_per_container] = [
  min_container_size,
  mem_total / node[:hadoop2][:yarn][:containers],
].max

default[:hadoop2][:pig][:version] = "0.13.0"
default[:hadoop2][:pig][:default_jars] = %w{
  http://search.maven.org/remotecontent?filepath=com/googlecode/json-simple/json-simple/1.1.1/json-simple-1.1.1.jar
  http://search.maven.org/remotecontent?filepath=com/twitter/elephantbird/elephant-bird-pig/4.5/elephant-bird-pig-4.5.jar
  http://search.maven.org/remotecontent?filepath=com/twitter/elephantbird/elephant-bird-hadoop-compat/4.5/elephant-bird-hadoop-compat-4.5.jar
  http://search.maven.org/remotecontent?filepath=org/apache/pig/piggybank/0.13.0/piggybank-0.13.0.jar
  http://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/5.1.29/mysql-connector-java-5.1.29.jar
  http://search.maven.org/remotecontent?filepath=com/linkedin/datafu/datafu/1.2.0/datafu-1.2.0.jar
  https://assets.remerge.io.s3.amazonaws.com/commons-codec-1.9.jar
}

default[:hadoop2][:fs][:s3][:access_key] = nil
default[:hadoop2][:fs][:s3][:secret_key] = nil

default[:hadoop2][:du][:reserved] = 0
default[:hadoop2][:decommissioning] = []

# HDFS cleanup script
default[:hadoop2][:hdfs][:clean] = {}
