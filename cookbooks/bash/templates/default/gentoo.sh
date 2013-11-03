# systemd goodies
_systemd_running() {
	[[ $(</proc/1/cmdline) =~ systemd ]]
}

alias cgls=systemd-cgls
alias cgtop=systemd-cgtop

sc() {
	if [[ $USER == "root" ]]; then
		systemctl $*
	else
		systemctl --user $*
	fi
}

jf() {
	journalctl --full -f -n 50 "$@"
}

# init script helpers
sva () {
	for svc in "$@"; do
		service start ${svc}
	done
}

svo () {
	for svc in "$@"; do
		service stop ${svc}
	done
}

svr () {
	for svc in "$@"; do
		service restart ${svc}
	done
}

# portdir helpers
eportdir() {
	if [[ -n "${PORTDIR_CACHE}" ]]; then
		echo "${PORTDIR_CACHE}"
	elif [[ -d /usr/portage ]]; then
		PORTDIR_CACHE="/usr/portage"
		eportdir
	else
		PORTDIR_CACHE="$(portageq portdir)"
		eportdir
	fi
}

echo1() { echo "$1"; }

efind() {
	local d cat pkg
	d=$(eportdir)

	case $1 in
		*-*/*)
			pkg=${1##*/}
			cat=${1%/*}
			;;

		?*)
			pkg=${1}
			cat=$(echo1 ${d}/*-*/${pkg}/*.ebuild)
			[[ -f $cat ]] || cat=$(echo1 ${d}/*-*/${pkg}*/*.ebuild)
			[[ -f $cat ]] || cat=$(echo1 ${d}/*-*/*${pkg}/*.ebuild)
			[[ -f $cat ]] || cat=$(echo1 ${d}/*-*/*${pkg}*/*.ebuild)
			if [[ ! -f $cat ]]; then
				return 1
			fi
			pkg=${cat%/*}
			pkg=${pkg##*/}
			cat=${cat#${d}/}
			cat=${cat%%/*}
		;;
	esac

	echo ${cat}/${pkg}
}

ecd() {
	local pc d
	pc=$(efind $@)
	d=$(eportdir)
	[[ $pc == "" ]] && return 1
	cd ${d}/${pc}
}

usedesc() {
	local d
	d=$(eportdir)
	
	echo "global:"
	grep "$1 - " ${d}/profiles/use.desc
	
	echo "local:"
	grep ":$1 - " ${d}/profiles/use.local.desc
}

mklnx() {
	set -e

	kernel_version=$(make kernelversion)
	tmpdir=$(mktemp -d)

	# build kernel
	make "$@"
	mkdir ${tmpdir}/boot
	cp .config ${tmpdir}/boot/config-${kernel_version}
	cp arch/x86/boot/bzImage ${tmpdir}/boot/kernel-${kernel_version}

	# build modules
	make INSTALL_MOD_PATH=${tmpdir} modules_install

	# install virtualbox modules
	ROOT=${tmpdir} KERNEL_DIR=$(realpath $PWD) \
		emerge --getbinpkg=n --usepkg=n --nodeps \
		app-emulation/virtualbox-modules

	# generate initramfs
	emerge dracut -u
	dracut --force ${tmpdir}/boot/initramfs-${kernel_version}.img

	# cleanup and install to /
	rm -rf ${tmpdir}/{etc,tmp,usr,var}
	rsync -rltgoDK ${tmpdir}/ /

	# create image
	tar cvf linux-${kernel_version}.tar -C ${tmpdir} .
	xz linux-${kernel_version}.tar
	rm -rf ${tmpdir}

	echo "Image is at $(realpath linux-${kernel_version}.tar.xz)"

	set +e
}
