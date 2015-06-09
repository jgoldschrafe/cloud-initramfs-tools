#!/bin/bash

check() {
	return 0
}

depends() {
	return 0
}

install() {
	inst_hook pre-pivot 00 "$moddir/growroot.sh"

	dracut_install awk
	dracut_install growpart
	dracut_install sfdisk
	dracut_install sgdisk
}

# vi: ts=4 noexpandtab
