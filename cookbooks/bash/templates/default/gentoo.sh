# init script helpers
sva () {
	for svc in "$@"; do
		/etc/init.d/${svc} start
	done
}

svo () {
	for svc in "$@"; do
		/etc/init.d/${svc} stop
	done
}

svr () {
	for svc in "$@"; do
		/etc/init.d/${svc} restart
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
	# build kernel
	pushd /usr/src/linux
	local KV=$(make kernelversion)
	make "$@" || exit 1
	cp arch/x86/boot/bzImage /boot/kernel-${KV} || exit 1
	popd

	# build initramfs
	dracut --force /boot/initramfs-${KV}.img || exit 1

	if partx -s -o SCHEME /dev/sda | grep -q gpt; then
		sed -i -e '/^GRUB_CMDLINE_LINUX=/s/=.*/="rd.md=1 rd.lvm=1 rd.lvm.vg=vg"/' /etc/default/grub || exit 1
		mkdir -p /boot/grub2 || exit 1
		grub2-mkconfig -o /boot/grub2/grub.cfg || exit 1

		for device in /dev/sd?; do
			grub2-install ${device}
		done
	fi
}
