#!/bin/bash

tmpdir=$(mktemp -d)

pushd ${tmpdir} > /dev/null

git clone https://github.com/zenops/cookbooks chef

pushd chef > /dev/null
rake server:bootstrap[chef.local,vagrant]
popd > /dev/null

mv chef /home/vagrant/chef
chown vagrant: -R /home/vagrant/chef

popd > /dev/null

rm -rf ${tmpdir}
