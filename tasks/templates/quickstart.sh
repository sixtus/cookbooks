#!/bin/bash
cd /tmp
wget -q -O quickstart.tar.gz https://github.com/zentoo/quickstart/tarball/next
tar -xzf quickstart.tar.gz
cd *-quickstart-*
exec ./quickstart profiles/<%= args.profile %>.sh
