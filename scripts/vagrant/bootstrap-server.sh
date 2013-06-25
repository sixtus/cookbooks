#!/bin/bash

export LANG=en_US.UTF-8

FQDN="chef.zenops.ws"
LOGIN="vagrant"
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"

# sync & update first
emerge --sync
eix-update

if [[ -d /home/vagrant/chef ]]; then
	echo "VM has already been bootstrapped, just calling chef-client"
	chef-client
else
	echo "VM is pristine, bootstrapping with rake server:bootstrap"

	git clone https://github.com/zenops/cookbooks /home/vagrant/chef

	pushd /home/vagrant/chef
	rake server:bootstrap[${FQDN},${LOGIN},"${SSH_KEY}"] || exit 1
	git add -A . || exit 1
	git commit -m "initial commit after bootstrapping chef-server on ${FQDN}"
	chown vagrant: -R . || exit 1
	popd
fi
