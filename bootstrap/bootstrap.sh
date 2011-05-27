#!/bin/bash
exec chef-solo \
	-L /dev/stdout \
	-c /root/chef/bootstrap/solo.rb \
	-j /root/chef/bootstrap/bootstrap.json
