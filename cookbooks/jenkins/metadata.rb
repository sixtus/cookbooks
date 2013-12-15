# encoding: utf-8

description "Jenkins continuous integration server"

maintainer "Benedikt Böhm"
maintainer_email "bb@xnull.de"
license "Apache v2.0"

version "4.1.0"

supports "gentoo"

depends "java"
depends "nginx"
depends "systemd"
depends "openssl"
depends "shorewall"
