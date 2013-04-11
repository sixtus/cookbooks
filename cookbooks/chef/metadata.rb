# encoding: utf-8

description "The Chef Server"

maintainer "Benedikt Böhm"
maintainer_email "bb@xnull.de"
license "Apache v2.0"

version "2.1.2"

supports "gentoo"

depends "couchdb"
depends "java"
depends "nagios"
depends "nginx"
depends "openssl"
depends "rabbitmq"
depends "splunk"
