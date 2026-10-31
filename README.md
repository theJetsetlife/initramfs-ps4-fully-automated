README
A modified initramfs-ps4 (v0.13.0) that installs a Linux distro on a jailbroken PS4 and boots it with no keyboard. It has been syntax-checked but not tested on hardware.

What it does
On boot, the initramfs looks for an installed linux.img and mounts it as the root filesystem. If it finds none, it installs the distro from a tarball automatically, then boots.

It looks in this order:

A partition labelled psxitarch (two-partition USB layout).
linux.img in the root of the first partition of a USB drive.
/user/system/boot/linux.img, then /user/app/linux.img on the PS4 internal drive (not on Baikal consoles).
An existing linux.img is never overwritten by the automatic installs.

Install to a USB drive
Format a USB drive as FAT32.
Copy bzImage, initramfs.cpio.gz and distro.tar.xz to the root of its first partition.
Boot from it.
auto-install-ext.sh creates linux.img on that same partition, formats it ext4 and extracts the distro into it. The drive is not repartitioned or erased.

Settings are at the top of the script: SIZE_MB (0 = as large as possible), MARGIN_MB (16), MIN_MB (512).

On FAT32, linux.img is limited to 4095 MB.
FAT cannot create sparse files, so the whole image is written out. This can take several minutes.
If the install fails, the partial image is deleted, the LED turns orange and you get a rescue shell.
HDD key (internal drive only)
Opening the PS4 internal drive needs your console's EAP HDD key, eap_hdd_key.bin (32 bytes). It is unique to each console and is not included in the release. The USB install does not need it.

Dump it on the console with the EAPDumper payload, run through GoldHEN. It saves the key to /data/hddeap/ and, if a USB drive is plugged in, to the USB drive. Check that your firmware is on its supported list.
Put the file at key/eap_hdd_key.bin inside the initramfs. As root:
mkdir initramfs && cd initramfs
zcat ../initramfs.cpio.gz | cpio -idm
cp /path/to/eap_hdd_key.bin key/
find . | cpio -o -H newc -R 0:0 | gzip -9 > ../initramfs.cpio.gz
Without the key, internal install and internal boot fail with "No /key/eap_hdd_key.bin, the internal drive can not be opened." Never publish a build that contains your key.

Install to the internal drive
Put distro.tar.xz in /user/system/boot/ (or /user/system/) on the PS4 over FTP and boot. auto-install-int.sh creates /user/system/boot/linux.img, formats it, and extracts the distro into it.

Settings are at the top of the script: SIZE_GB (200, sparse), MARGIN_GB (10), MIN_GB (20), FS (ext4 or btrfs).

Aeolia and Belize consoles only. Baikal consoles must use the USB install.

Files
Item	Detail
Distro tarball name	distro.tar.xz (.tar.gz, .tar.bz2 and .tar also work)
FTP /user/...	The scripts' /ps4hdd/...
key/eap_hdd_key.bin	Your console's HDD key, needed to open the internal drive; leave it out of anything you publish
Manual scripts (rescue shell)
Script	Purpose
install-linux-ext.sh	USB install with prompts
install-linux-ext-2usb.sh	Original two-USB install (erases the target drive)
install-linux-int.sh	Internal install with prompts
dw-linux-int.sh	Download a tarball over ethernet, then install internally
find-install.sh, resume-boot	Find an installation and continue booting

Claude finished the response
