# encoding: utf-8

name "chef"
description "The Chef Server"

maintainer "Benedikt Böhm"
maintainer_email "bb@xnull.de"
license "Apache v2.0"

supports "debian"
supports "gentoo"

depends "java"
depends "nagios"
depends "nginx"
depends "ohai"
depends "openssl"
