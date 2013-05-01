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
	journalctl -f -n${1:-20}
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
	tmpdir=$(mktemp -d)

	KV=$(make kernelversion)

	make "$@"
	make INSTALL_MOD_PATH=${tmpdir} modules_install

	mkdir ${tmpdir}/boot
	cp .config ${tmpdir}/boot/config-${KV}
	cp arch/x86/boot/bzImage ${tmpdir}/boot/kernel-${KV}

	dracut --force ${tmpdir}/boot/initramfs-${KV}.img

	tar cvf linux-${KV}.tar -C ${tmpdir} .
	xz linux-${KV}.tar
	rm -rf ${tmpdir}

	echo "Image is at $(realpath linux-${KV}.tar.xz)"
}
