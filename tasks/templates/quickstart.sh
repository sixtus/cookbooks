#!/bin/bash

vgchange -a n

for i in /dev/md*; do
	mdadm -S $i
done

cd /tmp
wget -q -O quickstart.tar.gz https://github.com/zentoo/quickstart/tarball/master
tar -xzf quickstart.tar.gz
cd *-quickstart-*
exec ./quickstart profiles/<%= args.profile %>.sh
