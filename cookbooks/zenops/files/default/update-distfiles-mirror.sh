#!/bin/bash

export DISTDIR="/var/cache/mirror/zentoo/distfiles.new"
export PORTDIR="/var/cache/mirror/zentoo/portage"
export PORTDIR_OVERLAY=""

export GENTOO_MIRRORS="http://mirror.zenops.net/zentoo http://mirror.zenops.net http://ftp.spline.de/pub/gentoo"
export FEATURES="mirror lmirror"

export FETCHCOMMAND="/usr/bin/wget -t 1 -T 5 -nv --passive-ftp -O \"\${DISTDIR}/\${FILE}\" \"\${URI}\""
export RESUMECOMMAND="/usr/bin/wget -c -t 1 -T 5 -nv --passive-ftp -O \"\${DISTDIR}/\${FILE}\" \"\${URI}\""

mkdir -p ${DISTDIR}

pushd ${PORTDIR}

for i in $(find . -name '*.ebuild'); do
	ebuild $i fetch
done

popd

rsync -rltp --delete ${DISTDIR}/ ${DISTDIR/.new}/

rm -rf ${DISTDIR}
