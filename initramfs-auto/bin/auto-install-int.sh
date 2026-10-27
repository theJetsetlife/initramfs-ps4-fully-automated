#!/bin/sh
# One-time UNATTENDED internal install (Aeolia/Belize only). No keyboard needed.
# Edit these two values to change the install:
SIZE_GB=200         # wanted size of /user/app/linux.img in GB (sparse file)
MARGIN_GB=10        # if the drive has less free than SIZE_GB, use (free - MARGIN_GB) instead
MIN_GB=20           # never go below this; skip the install instead
FS=ext4             # ext4 or btrfs

. /functions.sh

boot=/ps4hdd/system/boot
img=/ps4hdd/app/linux.img

fail() {
	eerror "AUTO-INSTALL FAILED: $*"
	umount /newroot 2>/dev/null
	rm -f "${img}"
	ps4_change_led orange
	exit 1
}

if ps4_is_southbridge "baikal"; then
	ewarn "AUTO-INSTALL: Baikal consoles are not supported for internal install. Skipping."
	exit 0
fi

if ! mountpoint -q /ps4hdd; then
	ps4hdd_open
fi
if ! mountpoint -q /ps4hdd; then
	ewarn "AUTO-INSTALL: internal drive is not open (missing key?). Skipping."
	exit 0
fi

if [ -e "${img}" ]; then
	ewarn "AUTO-INSTALL: ${img} already exists. Not touching it."
	exit 0
fi

if ! distro="$(ps4_find_distro /ps4hdd/system)" && ! distro="$(ps4_find_distro "${boot}")"; then
	ewarn "AUTO-INSTALL: no distro.tar.xz found in /ps4hdd/system or ${boot}. Skipping."
	exit 0
fi

mkdir -p /ps4hdd/app
free_gb="$(df -Pk /ps4hdd | awk 'END { print int($4 / 1048576) }')"
if [ "${free_gb}" -lt "${SIZE_GB}" ]; then
	ewarn "AUTO-INSTALL: only ${free_gb} GB free, wanted ${SIZE_GB} GB."
	SIZE_GB=$((free_gb - MARGIN_GB))
	if [ "${SIZE_GB}" -lt "${MIN_GB}" ]; then
		ewarn "AUTO-INSTALL: not enough free space (${free_gb} GB). Skipping."
		exit 0
	fi
	ewarn "AUTO-INSTALL: using ${SIZE_GB} GB instead."
fi

einfo "AUTO-INSTALL: creating ${SIZE_GB} GB ${FS} image at ${img}"
dd if=/dev/null of="${img}" bs=1048576 count=0 seek="$((SIZE_GB * 1024))" 2>/dev/null || fail "could not create image"

case "${FS}" in
	ext4)  mkfs.ext4 -q -F -O ^orphan_file,^metadata_csum_seed "${img}" ;;
	btrfs) mkfs.btrfs -q -f "${img}" ;;
	*)     fail "unknown FS '${FS}'" ;;
esac || fail "could not format image"

mount "${img}" /newroot || fail "could not mount image"

einfo "AUTO-INSTALL: extracting $(basename "${distro}"), do not turn off the PS4..."
ps4_extract "${distro}" || fail "extraction failed"
ps4_prepare_newroot
sync
einfo "AUTO-INSTALL COMPLETE. Booting..."
exit 0
