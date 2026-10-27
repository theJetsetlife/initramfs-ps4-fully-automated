# initramfs-ps4-fully-automated
initramfs from https://github.com/GayCorp/initramfs-ps4/releases/tag/latest with a slight modification to allow for a no-keyboard install.

Automatically makes a 200GB linux.img in /user/data/linux.img. Supply your own eap_hdd_key.bin and put it in /initramfs/key/eap_hdd_key.bin for internal HDD support. (slim and fat may not work) &     EAP key dumping on FW13.52 is not yet supported.
