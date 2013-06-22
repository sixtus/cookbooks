#!/bin/bash

# sync & update first
emerge --sync
eix-update

if [[ -d /home/vagrant/chef ]]; then
	echo "VM has already been bootstrapped, just calling chef-client"
	chef-client
else
	echo "VM is pristine, bootstrapping with rake server:bootstrap"

	tmpdir=$(mktemp -d)
	pushd ${tmpdir} > /dev/null

	git clone https://github.com/zenops/cookbooks chef

	pushd chef > /dev/null
	rake server:bootstrap[chef.local,vagrant] || exit 1
	popd > /dev/null

	mv chef /home/vagrant/chef
	chown vagrant: -R /home/vagrant/chef

	popd > /dev/null
	rm -rf ${tmpdir}
fi
