#!/bin/bash

cmd=$1
shift

zookeeper="<%= zookeeper_connect(node[:kafka][:zookeeper][:root], node[:kafka][:zookeeper][:cluster]) %>"

case ${cmd} in
	c|consumer)
		/var/app/kafka/current/bin/kafka-console-consumer.sh --zookeeper ${zookeeper} "$@"
		;;
	p|producer)
		/var/app/kafka/current/bin/kafka-console-producer.sh --zookeeper ${zookeeper} "$@"
		;;
	t|topics)
		/var/app/kafka/current/bin/kafka-topics.sh --zookeeper ${zookeeper} "$@"
		;;
	r|run)
		class=$1
		shift
		/var/app/kafka/current/bin/kafka-run-class.sh ${class} --zookeeper ${zookeeper} "$@"
		;;
esac
